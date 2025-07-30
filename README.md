# Molecular-Dynamics-Simulations-Using-AMBER-ForceField

This repository houses the scripts and data for a series of molecular dynamics (MD) simulations performed using GROMACS software, employing the AMBER force field. The simulations investigate the dynamic behavior of various protein systems, including:
* Apo Protein: Simulations of the protein in its unbound, native state to understand its intrinsic conformational dynamics and stability.
* Ligand-Bound Protein Complex: MD simulations of the protein in complex with a specific ligand to elucidate the binding interactions, conformational changes induced by ligand binding, and the stability of the complex.
* Ligand-Bound Metalloprotein Complex: Simulations focusing on metalloproteins with a bound ligand, specifically examining the coordination sphere of the metal ion, its interaction with the ligand and protein residues, and the overall structural and dynamic implications.

This resource is designed to provide a comprehensive workflow for setting up, running, and analyzing MD simulations of diverse biological systems using GROMACS and the AMBER force field. It serves as a valuable reference for researchers interested in protein dynamics, ligand binding, and metalloprotein interactions.

# Installtion Steps
### Create a conda environment:
conda create -n md-gmx python=3.9 -y 

activate md-gmx

### Install ACPYPE for ligand topology generation:
conda install conda-forge::acpype -y  

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
