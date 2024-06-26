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
            --Subjlist=*)
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
Subjlist="sub-233 sub-234 sub-235 sub-236 sub-237 sub-238 sub-239 sub-240 sub-241 sub-242 sub-243 sub-244 sub-245 sub-246 sub-559 sub-561 sub-562 sub-563" #Space delimited list of subject IDs
EnvironmentScript="/media/ubuntu//5a0ea278-2829-4adb-a52a-1ecb9f33a53b//home/chaw/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script

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
    QUEUE="-q long.q"
#fi

PRINTCOM=""
#PRINTCOM="echo"

########################################## INPUTS ########################################## 

#Scripts called by this script do assume they run on the results of the HCP minimal preprocesing pipelines from Q2

######################################### DO WORK ##########################################

# fMRINames is for single-run FIX data, set MR FIX settings to empty
fMRINames=""
mrfixNames="task-rest_dir-RL@task-rest_dir-LR"
mrfixConcatName="task-rest_dir-RL_LR"
mrfixNamesToUse="task-rest_dir-RL@task-rest_dir-LR"
OutfMRIName="task-rest_dir-RL_LR"

# For MR FIX, set fMRINames to empty
#fMRINames=""
# the original MR FIX parameter for what to concatenate
#mrfixNames="rfMRI_REST1_RL@rfMRI_REST1_LR@tfMRI_WM_RL@tfMRI_WM_LR@tfMRI_GAMBLING_RL@tfMRI_GAMBLING_LR@tfMRI_MOTOR_RL@tfMRI_MOTOR_LR@rfMRI_REST2_LR@rfMRI_REST2_RL@tfMRI_LANGUAGE_RL@tfMRI_LANGUAGE_LR@tfMRI_SOCIAL_RL@tfMRI_SOCIAL_LR@tfMRI_RELATIONAL_RL@tfMRI_RELATIONAL_LR@tfMRI_EMOTION_RL@tfMRI_EMOTION_LR"
# the original MR FIX concatenated name
#mrfixConcatName="fMRI_CONCAT"
# @-separate list of runs to use
#mrfixNamesToUse="rfMRI_REST1_RL@rfMRI_REST1_LR@rfMRI_REST2_LR@rfMRI_REST2_RL"
#OutfMRIName="rfMRI_REST_CONCAT"


HighPass="0"
fMRIProcSTRING="_Atlas_hp0_clean"
MSMAllTemplates="${HCPPIPEDIR}/global/templates/MSMAll"
RegName="MSMAll_InitalReg"
HighResMesh="164"
LowResMesh="32"
InRegName="MSMSulc"
MatlabMode="0" #Mode=0 compiled Matlab, Mode=1 interpreted Matlab, Mode=2 Octave

fMRINames=`echo ${fMRINames} | sed 's/ /@/g'`

for Subject in $Subjlist ; do
    echo "    ${Subject}"

    if [ -n "${command_line_specified_run_local}" ] ; then
        echo "About to run ${HCPPIPEDIR}/MSMAll/MSMAllPipeline.sh"
        queuing_command=""
    else
        echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/MSMAll/MSMAllPipeline.sh"
        queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
    fi

    ${queuing_command} ${HCPPIPEDIR}/MSMAll/MSMAllPipeline.sh \
        --path=${StudyFolder} \
        --subject=${Subject} \
        --fmri-names-list=${fMRINames} \
        --multirun-fix-names="${mrfixNames}" \
        --multirun-fix-concat-name="${mrfixConcatName}" \
        --multirun-fix-names-to-use="${mrfixNamesToUse}" \
        --output-fmri-name=${OutfMRIName} \
        --high-pass=${HighPass} \
        --fmri-proc-string=${fMRIProcSTRING} \
        --msm-all-templates=${MSMAllTemplates} \
        --output-registration-name=${RegName} \
        --high-res-mesh=${HighResMesh} \
        --low-res-mesh=${LowResMesh} \
        --input-registration-name=${InRegName} \
        --matlab-run-mode=${MatlabMode}
done


