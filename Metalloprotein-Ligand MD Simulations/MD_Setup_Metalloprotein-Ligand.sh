#!/bin/bash

GMX=gmx 

FILE="6WFJ_T58-MOD7-103.61.pdb"          #Protein-Ligand-Metal Ion complex file with ligand as UNL
grep "HETATM\|CONECT" $FILE > LIG.pdb
sed -i -e 's/UNL/LIG/g' LIG.pdb
sed -i.bak '/ZN/d' ./LIG.pdb             #In this script ZN metal ion has been considered beacuse ZN is available in the complex file
obabel -ipdb LIG.pdb -omol > LIG.mol
sed -i -e 's/MOL/LIG/g' LIG.mol
acpype -i LIG.mol -a gaff2
mkdir -p param/ligand
mv LIG* param/ligand/
mkdir -p param/receptor
grep "ATOM\|ZN" $FILE > receptor.pdb
mv receptor.pdb param/receptor/
tar -czvf param.tar.gz param

#---------  SIMU SETUP  -----------
FF=amber99sb-ildn	#AMBER99sb-ILDN force field used
WATER=tip3p      	#Water Model used in the simulations
BOXTYPE=cubic    	#Periodic boundary conditions shape
BOXSIZE=1        	#Periodic boundary conditions box size
NT=8             	#Number of CPU cores 
GPU_ID=0         	#Graphics card ID

WORK_DR=`pwd`
MDP=$WORK_DR/AMBER_P-L_METAL_MDP

yes | $GMX pdb2gmx -f param/receptor/receptor.pdb -o param/receptor/receptor_GMX.pdb -water $WATER -ff $FF -ignh -ss -merge all

sed -i -e 's/MOL/LIG/g' param/receptor/receptor_GMX.pdb param/ligand/LIG.acpype/LIG_NEW.pdb
grep -h ATOM param/receptor/receptor_GMX.pdb param/ligand/LIG.acpype/LIG_NEW.pdb > complex.pdb

sed -i -e 's/MOL /LIG /g' param/ligand/LIG.acpype/LIG_GMX.itp
sed -i -e 's/MOL /LIG /g' param/ligand/LIG.acpype/LIG_GMX.gro

cp param/ligand/LIG.acpype/LIG_GMX.* $WORK_DR
cp param/ligand/LIG.acpype/posre_LIG.itp $WORK_DR

echo '
; Ligand position restraints
#ifdef POSRES_LIG
#include "posre_LIG.itp"
#endif
' >> LIG_GMX.itp


cat topol.top | sed -e 's/forcefield.itp"/forcefield.itp"\n#include "LIG_GMX.itp"/' > topol.bak
sed -i -e 's/ #include/#include/g' topol.bak
mv topol.bak topol.top
echo "LIG   1" >> topol.top

$GMX editconf -f  complex.pdb -o complex_newbox.gro -d $BOXSIZE -bt $BOXTYPE -c
$GMX solvate -cp complex_newbox.gro -cs spc216.gro -o complex_solv.gro -p topol.top
$GMX grompp -f $MDP/ions.mdp -c complex_solv.gro -p topol.top -o ions.tpr --maxwarn 1
echo "SOL" | $GMX genion -s ions.tpr -o complex_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
$GMX grompp -f $MDP/em_steep.mdp -c complex_solv_ions.gro -p topol.top -o em_steep.tpr
$GMX mdrun -v -deffnm em_steep -nt $NT -gpu_id $GPU_ID
$GMX grompp -f $MDP/em_cg.mdp -c em_steep.gro -p topol.top -o em.tpr
$GMX mdrun -v -deffnm em -nt $NT -gpu_id $GPU_ID

echo -e '"Protein" | "ZN"\n q' | gmx make_ndx -f em.gro -o index.ndx
echo -e '"Protein" | "ZN" | "LIG"\n q' | gmx make_ndx -f em.gro -n index.ndx
echo -e '"Water" | "CL"\n q' | gmx make_ndx -f em.gro -n index.ndx

$GMX grompp -f $MDP/nvt_300.mdp -c em.gro -r em.gro -n index.ndx -p topol.top -o nvt_300.tpr
$GMX mdrun -v -deffnm nvt_300 -nt $NT -gpu_id $GPU_ID
$GMX grompp -f $MDP/npt.mdp -c nvt_300.gro -r nvt_300.gro -t nvt_300.cpt -n index.ndx -p topol.top -o npt_ab.tpr
$GMX mdrun -v -deffnm npt_ab -nt $NT -gpu_id $GPU_ID
$GMX grompp -f $MDP/md.mdp -c npt_ab.gro -t npt_ab.cpt -n index.ndx -p topol.top -o md_complex_prod.tpr
$GMX mdrun -v -deffnm md_complex_prod -nt $NT -gpu_id $GPU_ID
echo "Protein_ZN_LIG System" | $GMX trjconv -s md_complex_prod.tpr -f md_complex_prod.trr -center -pbc nojump -ur compact -o md_noPBC.xtc -n index.ndx
echo "Protein_ZN_LIG System" | $GMX trjconv -s md_complex_prod.tpr -f md_noPBC.xtc -fit rot+trans -o md_fit.xtc -n
rm -rf md_noPBC.xtc

echo "Backbone Backbone" | $GMX rms -s md_complex_prod.tpr -f md_fit.xtc -n index.ndx -o "Protein_"$FILE"_rmsd".xvg -tu ns 
echo "Protein" | $GMX rmsf -s md_complex_prod.tpr -f md_fit.xtc -n index.ndx -o "Protein_"$FILE"_rmsf".xvg -res
echo "LIG LIG" | $GMX rms -s md_complex_prod.tpr -f md_fit.xtc -n index.ndx -o "LIG_"$FILE"_rmsd".xvg -tu ns
echo "LIG" | $GMX rmsf -s md_complex_prod.tpr -f md_fit.xtc -o "LIG_"$FILE"_rmsf".xvg
