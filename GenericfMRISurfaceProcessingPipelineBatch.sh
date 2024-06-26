#!/bin/bash 

get_batch_options() {
    local arguments=("$@")

    unset command_line_specified_study_folder
    unset command_line_specified_subj_list
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
Subjlist="sub-243 sub-244 sub-245 sub-246 sub-559 sub-561 sub-562 sub-563" #Space delimited list of subject IDs sub-236 sub-237 sub-238 sub-239 sub-240 sub-241 sub-242  sub-209 sub-210 sub-211 sub-212 sub-213 sub-214 sub-215 sub-216 sub-217sub-014 sub-015 sub-016 sub-017 sub-018 sub-019 sub-020 sub-031 sub-032 sub-033 sub-034 sub-035 sub-036 sub-037 sub-038 sub-039 sub-040sub-179 sub-180 sub-182 sub-183 sub-184 sub-185 sub-186 sub-187 sub-188 sub-189 sub-190 sub-191sub-400 sub-401 sub-402 sub-403 sub-404 sub-405 sub-406 sub-407 sub-408 sub-409 sub-410 sub-411 sub-412 sub-413 sub-414 sub-415 sub-416 sub-417 sub-418 sub-419 sub-420 sub-421 sub-422 sub-423 sub-424 sub-425 sub-426 sub-427 sub-428 sub-430 sub-431 sub-432 sub-433 sub-434 sub-435 sub-436 sub-437 sub-438 sub-439 sub-440 sub-441 sub-442 sub-443 sub-444 sub-445 sub-446 sub-447 sub-448 sub-449 sub-450sub-202 sub-203 sub-204 sub-205 sub-206 sub-207 sub-208 sub-209 sub-210sub-518 sub-519 sub-520 sub-521 sub-522 sub-523 sub-524 sub-525 sub-526 sub-527 sub-528 sub-529
EnvironmentScript="/media/ubuntu//5a0ea278-2829-4adb-a52a-1ecb9f33a53b//home/chaw/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script
#StudyFolder="/home/chaw/hc0701/Rawdata" #Location of Subject folders (named by subjectID)
#Subjlist="sub-540 sub-557 sub-558" #Space delimited list of subject IDssub-546 sub-547 sub-548 sub-549 sub-550 sub-551 sub-552 sub-553 sub-554 sub-555sub-542 sub-543 sub-544 sub-545sub-537 sub-538 sub-539 sub-540 sub-174 sub-184 sub-189sub-541sub-537 sub-538 sub-539 sub-540 sub-541sub-530 sub-531 sub-532 sub-533 sub-534 sub-535 sub-536 sub-001 sub-002 sub-003 sub-004 sub-005 sub-006 sub-007 sub-008 sub-009 sub-010 sub-011 sub-012 sub-013 sub-081 sub-082 sub-083 sub-084 sub-085 sub-086 sub-087 sub-088 sub-089 sub-090 sub-091 sub-092 sub-093 sub-094 sub-095 sub-096 sub-097 sub-098 sub-099 sub-100 sub-178 sub-179 sub-180 sub-182 sub-183 sub-184 sub-185 sub-186 sub-187 sub-188 sub-189 sub-190 sub-191 sub-400 sub-401 sub-402 sub-403 sub-404 sub-405 sub-406 sub-407 sub-408 sub-409 sub-410 sub-411 sub-412 sub-413 sub-414 sub-415 sub-416 sub-417 sub-418 sub-419 sub-420 sub-421 sub-422 sub-423 sub-424 sub-425 sub-426 sub-427 sub-428 sub-430 sub-431 sub-432 sub-433 sub-434 sub-435 sub-436 sub-437 sub-438 sub-439 sub-440 sub-441 sub-442 sub-443 sub-444 sub-445 sub-446 sub-447 sub-448 sub-449 sub-450 sub-202 sub-203 sub-204 sub-205 sub-206 sub-207 sub-208 sub-209sub-105 sub-108 sub-113 sub-114 sub-115 sub-117 sub-118 sub-119 sub-122 sub-126 sub-139 sub-143 sub-146 sub-152 sub-153 sub-210sub-121 sub-122 sub-123 sub-124 sub-125 sub-126 sub-127 sub-128 sub-129 sub-130 sub-131 sub-132 sub-133 sub-134 sub-135 sub-136 sub-137 sub-138 sub-139 sub-140 sub-492sub-218sub-219 sub-220 sub-221 sub-222 sub-223 sub-224 sub-225 sub-226 sub-227 sub-228
#EnvironmentScript="${HOME}/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script

if [ -n "${command_line_specified_study_folder}" ]; then
    StudyFolder="${command_line_specified_study_folder}"
fi

if [ -n "${command_line_specified_subj}" ]; then
    Subjlist="${command_line_specified_subj}"
fi

# Requirements for this script
#  installed versions of: FSL, Connectome Workbench (wb_command)
#  environment: HCPPIPEDIR, FSLDIR, CARET7DIR

#Set up pipeline environment variables and software
source ${EnvironmentScript}

# Log the originating call
echo "$@"

#if [ X$SGE_ROOT != X ] ; then
#    QUEUE="-q long.q"
    QUEUE="-q hcp_priority.q"
#fi

PRINTCOM=""
#PRINTCOM="echo"

########################################## INPUTS ########################################## 

#Scripts called by this script do assume they run on the outputs of the FreeSurfer Pipeline

######################################### DO WORK ##########################################

Tasklist=""
Tasklist="${Tasklist} task-rest_dir-RL"
Tasklist="${Tasklist} task-rest_dir-LR"
#Tasklist="${Tasklist} rfMRI_REST2_RL"
#Tasklist="${Tasklist} rfMRI_REST2_LR"
#Tasklist="${Tasklist} tfMRI_EMOTION_RL"
#Tasklist="${Tasklist} tfMRI_EMOTION_LR"
#Tasklist="${Tasklist} tfMRI_GAMBLING_RL"
#Tasklist="${Tasklist} tfMRI_GAMBLING_LR"
#Tasklist="${Tasklist} tfMRI_LANGUAGE_RL"
#Tasklist="${Tasklist} tfMRI_LANGUAGE_LR"
#Tasklist="${Tasklist} tfMRI_MOTOR_RL"
#Tasklist="${Tasklist} tfMRI_MOTOR_LR"
#Tasklist="${Tasklist} tfMRI_RELATIONAL_RL"
#Tasklist="${Tasklist} tfMRI_RELATIONAL_LR"
#Tasklist="${Tasklist} tfMRI_SOCIAL_RL"
#Tasklist="${Tasklist} tfMRI_SOCIAL_LR"
#Tasklist="${Tasklist} tfMRI_WM_RL"
#Tasklist="${Tasklist} tfMRI_WM_LR"

for Subject in $Subjlist ; do
  echo $Subject

  for fMRIName in $Tasklist ; do
    echo "  ${fMRIName}"
    LowResMesh="32" #Needs to match what is in PostFreeSurfer, 32 is on average 2mm spacing between the vertices on the midthickness
    FinalfMRIResolution="2" #Needs to match what is in fMRIVolume, i.e. 2mm for 3T HCP data and 1.6mm for 7T HCP data
    SmoothingFWHM="2" #Recommended to be roughly the grayordinates spacing, i.e 2mm on HCP data 
    GrayordinatesResolution="2" #Needs to match what is in PostFreeSurfer. 2mm gives the HCP standard grayordinates space with 91282 grayordinates.  Can be different from the FinalfMRIResolution (e.g. in the case of HCP 7T data at 1.6mm)
    RegName="MSMSulc" #MSMSulc is recommended, if binary is not available use FS (FreeSurfer)
    
    if [ -n "${command_line_specified_run_local}" ] ; then
        echo "About to run ${HCPPIPEDIR}/fMRISurface/GenericfMRISurfaceProcessingPipeline.sh"
        queuing_command=""
    else
        echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/fMRISurface/GenericfMRISurfaceProcessingPipeline.sh"
        queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
    fi

    ${queuing_command} ${HCPPIPEDIR}/fMRISurface/GenericfMRISurfaceProcessingPipeline.sh \
      --path=$StudyFolder \
      --subject=$Subject \
      --fmriname=$fMRIName \
      --lowresmesh=$LowResMesh \
      --fmrires=$FinalfMRIResolution \
      --smoothingFWHM=$SmoothingFWHM \
      --grayordinatesres=$GrayordinatesResolution \
      --regname=$RegName

  # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...

      echo "set -- --path=$StudyFolder \
      --subject=$Subject \
      --fmriname=$fMRIName \
      --lowresmesh=$LowResMesh \
      --fmrires=$FinalfMRIResolution \
      --smoothingFWHM=$SmoothingFWHM \
      --grayordinatesres=$GrayordinatesResolution \
      --regname=$RegName"

      echo ". ${EnvironmentScript}"
            
   done
done

