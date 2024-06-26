#!/bin/bash 

get_batch_options() {
    local arguments=("$@")

    unset command_line_specified_study_folder
    unset command_line_specified_subj
    unset command_line_specified_run_local

    local index=0
    local numArgs=${#arguments[@]}
    local argument

    while [ ${index} -lt ${numArgs} ]; do
        argument=${arguments[index]}

        case ${argument} in
            --StudyFolder=*)
                command_line_specified_study_folder=${argument#*=}
                index=$(( index + 1 ))
                ;;
            --Subject=*)
                command_line_specified_subj=${argument#*=}
                index=$(( index + 1 ))
                ;;
            --runlocal)
                command_line_specified_run_local="TRUE"
                index=$(( index + 1 ))
                ;;
	    *)
		echo ""
		echo "ERROR: Unrecognized Option: ${argument}"
		echo ""
		exit 1
		;;
        esac
    done
}

get_batch_options "$@"

StudyFolder="/media/ubuntu/NCU/deng/Rawdata" #Location of Subject folders (named by subjectID)
Subjlist="sub-236 sub-237 sub-238 sub-239 sub-240 sub-241 sub-242 sub-243 sub-244 sub-245 sub-246 sub-559 sub-561 sub-562 sub-563" #Space delimited list of subject IDs sub-209 sub-210 sub-211 sub-212 sub-213 sub-214 sub-215 sub-216 sub-217sub-014 sub-015 sub-016 sub-017 sub-018 sub-019 sub-020 sub-031 sub-032 sub-033 sub-034 sub-035 sub-036 sub-037 sub-038 sub-039 sub-040sub-179 sub-180 sub-182 sub-183 sub-184 sub-185 sub-186 sub-187 sub-188 sub-189 sub-190 sub-191sub-400 sub-401 sub-402 sub-403 sub-404 sub-405 sub-406 sub-407 sub-408 sub-409 sub-410 sub-411 sub-412 sub-413 sub-414 sub-415 sub-416 sub-417 sub-418 sub-419 sub-420 sub-421 sub-422 sub-423 sub-424 sub-425 sub-426 sub-427 sub-428 sub-430 sub-431 sub-432 sub-433 sub-434 sub-435 sub-436 sub-437 sub-438 sub-439 sub-440 sub-441 sub-442 sub-443 sub-444 sub-445 sub-446 sub-447 sub-448 sub-449 sub-450sub-202 sub-203 sub-204 sub-205 sub-206 sub-207 sub-208 sub-209 sub-210sub-518 sub-519 sub-520 sub-521 sub-522 sub-523 sub-524 sub-525 sub-526 sub-527 sub-528 sub-529
EnvironmentScript="/media/ubuntu//5a0ea278-2829-4adb-a52a-1ecb9f33a53b//home/chaw/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pi
#StudyFolder="/home/chaw/hc0701/Rawdata" #Location of Subject folders (named by subjec#tID)
#Subjlist="sub-540 sub-557 sub-558" #Space delimited list of subject IDs sub-174 sub-184 sub-189sub-546 sub-547 sub-548 sub-549 sub-550 sub-551 sub-552 sub-553 sub-554 sub-555 sub-537 sub-538 sub-539 sub-540 sub-541sub-537 sub-538 sub-539 sub-540 sub-541sub-537 sub-538 sub-539 sub-540 sub-541sub-014 sub-015 sub-016 sub-017 sub-018 sub-019 sub-020 sub-031 sub-032 sub-033 sub-034 sub-035 sub-036 sub-037 sub-038 sub-039 sub-040sub-179 sub-180 sub-182 sub-183 sub-184 sub-185 sub-186 sub-187 sub-188 sub-189 sub-492sub-190 sub-191sub-400 sub-401 sub-402 sub-403 sub-404 sub-405 sub-406 sub-407 sub-408 sub-409 sub-410 sub-411 sub-412 sub-413 sub-414 sub-415 sub-416 sub-417 sub-418 sub-419 sub-420 sub-421 sub-422 sub-423 sub-424 sub-425 sub-426 sub-427 sub-428 sub-430 sub-431 sub-432 sub-433 sub-434 sub-435 sub-436 sub-437 sub-438 sub-439 sub-440 sub-441 sub-442 sub-443 sub-444 sub-445 sub-446 sub-447 sub-448 sub-449 sub-450sub-202 sub-203 sub-204 sub-205 sub-206 sub-207 sub-208 sub-209 sub-210sub-218sub-219 sub-220 sub-221 sub-222 sub-223 sub-224 sub-225 sub-226 sub-227 sub-228sub-542 sub-543 sub-544 sub-545
#EnvironmentScript="${HOME}/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script

if [ -n "${command_line_specified_study_folder}" ]; then
    StudyFolder="${command_line_specified_study_folder}"
fi

if [ -n "${command_line_specified_subj}" ]; then
    Subjlist="${command_line_specified_subj}"
fi

# Requirements for this script
#  installed versions of: FSL, FreeSurfer, Connectome Workbench (wb_command), gradunwarp (HCP version)
#  environment: HCPPIPEDIR, FSLDIR, FREESURFER_HOME, CARET7DIR, PATH for gradient_unwarp.py

#Set up pipeline environment variables and software
source ${EnvironmentScript}

# Log the originating call
echo "$@"

#if [ X$SGE_ROOT != X ] ; then
#    QUEUE="-q long.q"
    QUEUE="-q hcp_priority.q"
#fi

if [[ -n $HCPPIPEDEBUG ]]
then
    set -x
fi

PRINTCOM=""
#PRINTCOM="echo"
#QUEUE="-q veryshort.q"

########################################## INPUTS ########################################## 

# Scripts called by this script do NOT assume anything about the form of the input names or paths.
# This batch script assumes the HCP raw data naming convention.
#
# For example, if phase encoding directions are LR and RL, for tfMRI_EMOTION_LR and tfMRI_EMOTION_RL:
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_LR/${Subject}_3T_tfMRI_EMOTION_LR.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_LR/${Subject}_3T_tfMRI_EMOTION_LR_SBRef.nii.gz
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_RL/${Subject}_3T_tfMRI_EMOTION_RL.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_RL/${Subject}_3T_tfMRI_EMOTION_RL_SBRef.nii.gz
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_LR/${Subject}_3T_SpinEchoFieldMap_LR.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_LR/${Subject}_3T_SpinEchoFieldMap_RL.nii.gz
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_RL/${Subject}_3T_SpinEchoFieldMap_LR.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_RL/${Subject}_3T_SpinEchoFieldMap_RL.nii.gz
#
# If phase encoding directions are PA and AP:
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_PA/${Subject}_3T_tfMRI_EMOTION_PA.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_PA/${Subject}_3T_tfMRI_EMOTION_PA_SBRef.nii.gz
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_AP/${Subject}_3T_tfMRI_EMOTION_AP.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_AP/${Subject}_3T_tfMRI_EMOTION_AP_SBRef.nii.gz
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_PA/${Subject}_3T_SpinEchoFieldMap_PA.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_PA/${Subject}_3T_SpinEchoFieldMap_AP.nii.gz
#
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_AP/${Subject}_3T_SpinEchoFieldMap_PA.nii.gz
#	${StudyFolder}/${Subject}/unprocessed/3T/tfMRI_EMOTION_AP/${Subject}_3T_SpinEchoFieldMap_AP.nii.gz
#
#
# Change Scan Settings: EchoSpacing, FieldMap DeltaTE (if not using TOPUP),
# and $TaskList to match your acquisitions
#
# If using gradient distortion correction, use the coefficents from your scanner.
# The HCP gradient distortion coefficents are only available through Siemens.
# Gradient distortion in standard scanners like the Trio is much less than for the HCP 'Connectom' scanner.
#
# To get accurate EPI distortion correction with TOPUP, the phase encoding direction
# encoded as part of the ${TaskList} name must accurately reflect the PE direction of
# the EPI scan, and you must have used the correct images in the
# SpinEchoPhaseEncode{Negative,Positive} variables.  If the distortion is twice as
# bad as in the original images, either swap the
# SpinEchoPhaseEncode{Negative,Positive} definition or reverse the polarity in the
# logic for setting UnwarpDir.
# NOTE: The pipeline expects you to have used the same phase encoding axis and echo
# spacing in the fMRI data as in the spin echo field map acquisitions.

######################################### DO WORK ##########################################

SCRIPT_NAME=`basename ${0}`
echo $SCRIPT_NAME

TaskList=""
TaskList+=" task-rest_dir-RL"  #Include space as first character
TaskList+=" task-rest_dir-LR"
#TaskList+=" rfMRI_REST2_RL"
#TaskList+=" rfMRI_REST2_LR"
#TaskList+=" tfMRI_EMOTION_RL"
#TaskList+=" tfMRI_EMOTION_LR"
#TaskList+=" tfMRI_GAMBLING_RL"
#TaskList+=" tfMRI_GAMBLING_LR"
#TaskList+=" tfMRI_LANGUAGE_RL"
#TaskList+=" tfMRI_LANGUAGE_LR"
#TaskList+=" tfMRI_MOTOR_RL"
#TaskList+=" tfMRI_MOTOR_LR"
#TaskList+=" tfMRI_RELATIONAL_RL"
#TaskList+=" tfMRI_RELATIONAL_LR"
#TaskList+=" tfMRI_SOCIAL_RL"
#TaskList+=" tfMRI_SOCIAL_LR"
#TaskList+=" tfMRI_WM_RL"
#TaskList+=" tfMRI_WM_LR"

# Start or launch pipeline processing for each subject
for Subject in $Subjlist ; do
  echo "${SCRIPT_NAME}: Processing Subject: ${Subject}"

  i=1
  for fMRIName in $TaskList ; do
    echo "  ${SCRIPT_NAME}: Processing Scan: ${fMRIName}"
	  
	TaskName=`echo ${fMRIName} | sed 's/_[APLR]\+$//'`
	echo "  ${SCRIPT_NAME}: TaskName: ${TaskName}"

	len=${#fMRIName}
	echo "  ${SCRIPT_NAME}: len: $len"
	start=$(( len - 2 ))
		
	PhaseEncodingDir=${fMRIName:start:2}
	echo "  ${SCRIPT_NAME}: PhaseEncodingDir: ${PhaseEncodingDir}"
		
	case ${PhaseEncodingDir} in
	  "PA")
		UnwarpDir="y"
		;;
	  "AP")
		UnwarpDir="y-"
		;;
	  "RL")
		UnwarpDir="x"
		;;
	  "LR")
		UnwarpDir="x-"
		;;
	  *)
		echo "${SCRIPT_NAME}: Unrecognized Phase Encoding Direction: ${PhaseEncodingDir}"
		exit 1
	esac
	
	echo "  ${SCRIPT_NAME}: UnwarpDir: ${UnwarpDir}"
		
    fMRITimeSeries="${StudyFolder}/${Subject}/ses-1/${fMRIName}/${Subject}_ses-1_${fMRIName}_bold.nii.gz"

	# A single band reference image (SBRef) is recommended if available
	# Set to NONE if you want to use the first volume of the timeseries for motion correction
    fMRISBRef="${StudyFolder}/${Subject}/ses-1/${fMRIName}/${Subject}_ses-1_${fMRIName}_sbref.nii.gz"
	
	# "Effective" Echo Spacing of fMRI image (specified in *sec* for the fMRI processing)
	# EchoSpacing = 1/(BWPPPE * ReconMatrixPE)
	#   where BWPPPE is the "BandwidthPerPixelPhaseEncode" = DICOM field (0019,1028) for Siemens, and
	#   ReconMatrixPE = size of the reconstructed image in the PE dimension
	# In-plane acceleration, phase oversampling, phase resolution, phase field-of-view, and interpolation
	# all potentially need to be accounted for (which they are in Siemen's reported BWPPPE)
    EchoSpacing="0.00058" 

	# Susceptibility distortion correction method (required for accurate processing)
	# Values: TOPUP, SiemensFieldMap (same as FIELDMAP), GeneralElectricFieldMap
    DistortionCorrection="TOPUP"

	# Receive coil bias field correction method
	# Values: NONE, LEGACY, or SEBASED
	#   SEBASED calculates bias field from spin echo images (which requires TOPUP distortion correction)
	#   LEGACY uses the T1w bias field (method used for 3T HCP-YA data, but non-optimal; no longer recommended).
	BiasCorrection="SEBASED"

	# For the spin echo field map volume with a 'negative' phase encoding direction
	# (LR in HCP-YA data; AP in 7T HCP-YA and HCP-D/A data)
	# Set to NONE if using regular FIELDMAP
    SpinEchoPhaseEncodeNegative="${StudyFolder}/${Subject}/ses-1/fmap/${Subject}_ses-1_dir-LR_epi.nii.gz"

	# For the spin echo field map volume with a 'positive' phase encoding direction
	# (RL in HCP-YA data; PA in 7T HCP-YA and HCP-D/A data)
	# Set to NONE if using regular FIELDMAP
    SpinEchoPhaseEncodePositive="${StudyFolder}/${Subject}/ses-1/fmap/${Subject}_ses-1_dir-RL_epi.nii.gz"

	# Topup configuration file (if using TOPUP)
	# Set to NONE if using regular FIELDMAP
    TopUpConfig="${HCPPIPEDIR_Config}/b02b0.cnf"

	# Not using Siemens Gradient Echo Field Maps for susceptibility distortion correction
	# Set following to NONE if using TOPUP
	MagnitudeInputName="NONE" #Expects 4D Magnitude volume with two 3D volumes (differing echo times)
    PhaseInputName="NONE" #Expects a 3D Phase difference volume (Siemen's style)
    DeltaTE="NONE" #2.46ms for 3T, 1.02ms for 7T
	
    # Path to General Electric style B0 fieldmap with two volumes
    #   1. field map in degrees
    #   2. magnitude
    # Set to "NONE" if not using "GeneralElectricFieldMap" as the value for the DistortionCorrection variable
    #
    # Example Value: 
    #  GEB0InputName="${StudyFolder}/${Subject}/unprocessed/3T/${fMRIName}/${Subject}_3T_GradientEchoFieldMap.nii.gz" 
    GEB0InputName="NONE"

	# Target final resolution of fMRI data
	# 2mm is recommended for 3T HCP data, 1.6mm for 7T HCP data (i.e. should match acquisition resolution)
	# Use 2.0 or 1.0 to avoid standard FSL templates
    FinalFMRIResolution="2"

	# Gradient distortion correction
	# Set to NONE to skip gradient distortion correction
	# (These files are considered proprietary and therefore not provided as part of the HCP Pipelines -- contact Siemens to obtain)
    # GradientDistortionCoeffs="${HCPPIPEDIR_Config}/coeff_SC72C_Skyra.grad"
    GradientDistortionCoeffs="NONE"

    # Type of motion correction
	# Values: MCFLIRT (default), FLIRT
	# (3T HCP-YA processing used 'FLIRT', but 'MCFLIRT' now recommended)
    MCType="MCFLIRT"
		
    if [ -n "${command_line_specified_run_local}" ] ; then
        echo "About to run ${HCPPIPEDIR}/fMRIVolume/GenericfMRIVolumeProcessingPipeline.sh"
        queuing_command=""
    else
        echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/fMRIVolume/GenericfMRIVolumeProcessingPipeline.sh"
        queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
    fi

    ${queuing_command} ${HCPPIPEDIR}/fMRIVolume/GenericfMRIVolumeProcessingPipeline.sh \
      --path=$StudyFolder \
      --subject=$Subject \
      --fmriname=$fMRIName \
      --fmritcs=$fMRITimeSeries \
      --fmriscout=$fMRISBRef \
      --SEPhaseNeg=$SpinEchoPhaseEncodeNegative \
      --SEPhasePos=$SpinEchoPhaseEncodePositive \
      --fmapmag=$MagnitudeInputName \
      --fmapphase=$PhaseInputName \
      --fmapgeneralelectric=$GEB0InputName \
      --echospacing=$EchoSpacing \
      --echodiff=$DeltaTE \
      --unwarpdir=$UnwarpDir \
      --fmrires=$FinalFMRIResolution \
      --dcmethod=$DistortionCorrection \
      --gdcoeffs=$GradientDistortionCoeffs \
      --topupconfig=$TopUpConfig \
      --printcom=$PRINTCOM \
      --biascorrection=$BiasCorrection \
      --mctype=${MCType}

  # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...

  echo "set -- --path=$StudyFolder \
      --subject=$Subject \
      --fmriname=$fMRIName \
      --fmritcs=$fMRITimeSeries \
      --fmriscout=$fMRISBRef \
      --SEPhaseNeg=$SpinEchoPhaseEncodeNegative \
      --SEPhasePos=$SpinEchoPhaseEncodePositive \
      --fmapmag=$MagnitudeInputName \
      --fmapphase=$PhaseInputName \
      --fmapgeneralelectric=$GEB0InputName \
      --echospacing=$EchoSpacing \
      --echodiff=$DeltaTE \
      --unwarpdir=$UnwarpDir \
      --fmrires=$FinalFMRIResolution \
      --dcmethod=$DistortionCorrection \
      --gdcoeffs=$GradientDistortionCoeffs \
      --topupconfig=$TopUpConfig \
      --printcom=$PRINTCOM \
      --biascorrection=$BiasCorrection \
      --mctype=${MCType}"

  echo ". ${EnvironmentScript}"
	
    i=$(($i+1))
  done
done


