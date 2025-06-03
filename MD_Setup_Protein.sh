#!/bin/bash
GMX=gmx #Specify the gromacs path

FILE="Alpha_Protein_A.pdb"

#---------  SIMU SETUP  -----------
FF=amber99sb-ildn	#AMBER99sb-ILDN force field used
WATER=tip3p      	#Water Model used in the simulations
BOXTYPE=cubic    	#Periodic boundary conditions shape
BOXSIZE=1        	#Periodic boundary conditions box size
NT=8             	#Number of CPU cores 
GPU_ID=0         	#Graphics card ID

WORK_DR=`pwd`
MDP=$WORK_DR/AMBER_Protein_MDP

yes | $GMX pdb2gmx -f $FILE -o protein.gro -water $WATER -ff $FF -ignh -ss -merge all

$GMX editconf -f  protein.pdb -o protein_newbox.gro -d $BOXSIZE -bt $BOXTYPE -c
$GMX solvate -cp protein_newbox.gro -cs spc216.gro -o protein_solv.gro -p topol.top
$GMX grompp -f $MDP/ions.mdp -c protein_solv.gro -p topol.top -o ions.tpr --maxwarn 1
echo "SOL" | $GMX genion -s ions.tpr -o protein_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
$GMX grompp -f $MDP/em_steep.mdp -c protein_solv_ions.gro -p topol.top -o em_steep.tpr
$GMX mdrun -v -deffnm em_steep -nt $NT -gpu_id $GPU_ID
$GMX grompp -f $MDP/em_cg.mdp -c em_steep.gro -p topol.top -o em.tpr
$GMX mdrun -v -deffnm em -nt $NT -gpu_id $GPU_ID

$GMX grompp -f $MDP/nvt_300.mdp -c em.gro -r em.gro -n index.ndx -p topol.top -o nvt_300.tpr
$GMX mdrun -v -deffnm nvt_300 -nt $NT -gpu_id $GPU_ID
$GMX grompp -f $MDP/npt.mdp -c nvt_300.gro -r nvt_300.gro -t nvt_300.cpt -n index.ndx -p topol.top -o npt_ab.tpr
$GMX mdrun -v -deffnm npt_ab -nt $NT -gpu_id $GPU_ID
$GMX grompp -f $MDP/md.mdp -c npt_ab.gro -t npt_ab.cpt -n index.ndx -p topol.top -o md_protein_prod.tpr
$GMX mdrun -v -deffnm md_protein_prod -nt $NT -gpu_id $GPU_ID
echo "Protein System" | $GMX trjconv -s md_complex_prod.tpr -f md_complex_prod.trr -center -pbc nojump -ur compact -o md_noPBC.xtc -n index.ndx
echo "Protein System" | $GMX trjconv -s md_protein_prod.tpr -f md_noPBC.xtc -fit rot+trans -o md_fit.xtc -n
rm -rf md_noPBC.xtc

echo "Backbone Backbone" | $GMX rms -s md_protein_prod.tpr -f md_fit.xtc -n index.ndx -o "Protein_"$FILE"_rmsd".xvg -tu ns 
echo "Protein" | $GMX rmsf -s md_protein_prod.tpr -f md_fit.xtc -n index.ndx -o "Protein_"$FILE"_rmsf".xvg -res