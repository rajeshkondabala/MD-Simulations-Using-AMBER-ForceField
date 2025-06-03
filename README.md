# Molecular-Dynamics-Simulations-Using-AMBER-ForceField

**Installtion Steps**

conda create -n md-gmx python=3.9 -y   #Create a conda environment

activate md-gmx

conda install conda-forge::acpype -y   #Install ACPYPE for ligand topology generation

#############################################################################################
#The user must either directly specify the GROMACS path in the MD_Setup_Protein.sh file or source it in the .bashrc file.
#############################################################################################
*Apo-Protein Molecular Dynamics Simulations*

Run MD_Setup_Protein using the following command

bash MD_Setup_Protein.sh

#############################################################################################

*Protein-Ligand Molecular Dynamics Simulations*
Run MD_Setup_Protein-Ligand using the following command

bash MD_Setup_Protein-Ligand.sh

############################################################################################
*Metalloprotein-Ligand Molecular Dynamics Simulations*

Run MD_Setup_Metalloprotein-Ligand using the following command

bash MD_Setup_Metalloprotein-Ligand.sh

###########################################################################################
