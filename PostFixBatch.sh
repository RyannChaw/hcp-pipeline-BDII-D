#!/bin/bash

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
Subjlist="sub-233 sub-234 sub-235 sub-236 sub-237 sub-238 sub-239 sub-240 sub-241 sub-242 sub-243 sub-244 sub-245 sub-246 sub-559 sub-561 sub-562 sub-563" #Space delimited list of subject IDs sub-530sub-700 sub-701 sub-704 sub-531 sub-401 sub-435 sub-455 sub-458 sub-459 sub-475 sub-478 sub-480 sub-483 sub-484 sub-486 sub-490 sub-503 sub-516 sub-524 sub-529sub-532 sub-533 sub-534 sub-535 sub-536 sub-219 sub-537 sub-546 sub-547 sub-548 sub-549 sub-550 sub-551 sub-552 sub-553 sub-174 sub-184 sub-189sub-554 sub-555sub-538 sub-539 sub-540 sub-541sub-220 sub-221 sub-222 sub-223 sub-224 sub-225 sub-226 sub-227 sub-228 sub-203 sub-204 sub-205 sub-206sub-218 sub-207 sub-208 sub-209 sub-210sub-203 sub-204 sub-205 sub-206 sub-207 sub-208 sub-209 sub-210sub-001 sub-003 sub-004 sub-005 sub-007 sub-008 sub-009 sub-013 sub-016 sub-017 sub-019 sub-020 sub-023 sub-029 sub-031 sub-033 sub-034 sub-035 sub-037 sub-040 sub-041 sub-042 sub-043 sub-044 sub-045 sub-047 sub-049 sub-050 sub-051 sub-053 sub-055 sub-056 sub-057 sub-058 sub-059 sub-061 sub-062 sub-063 sub-065 sub-066 sub-069 sub-070 sub-071 sub-072 sub-073 sub-074 sub-075 sub-076 sub-077 sub-078 sub-080 sub-081 sub-082 sub-083 sub-084 sub-085 sub-087 sub-088 sub-089 sub-090 sub-094 sub-095 sub-096 sub-104 sub-105 sub-107 sub-108 sub-113 sub-114 sub-115 sub-117 sub-118 sub-119 sub-120 sub-122 sub-123 sub-124 sub-126 sub-130 sub-132 sub-133 sub-135 sub-136 sub-139 sub-140 sub-141 sub-142 sub-143 sub-146 sub-148 sub-149 sub-150 sub-151 sub-152 sub-153 sub-154 sub-155 sub-158 sub-161 sub-162 sub-163 sub-164 sub-165 sub-167 sub-168 sub-169 sub-170 sub-171 sub-172 sub-173 sub-174 sub-175 sub-176 sub-177 sub-178 sub-179 sub-180 sub-181 sub-182 sub-183 sub-184 sub-187 sub-192 sub-193 sub-194 sub-195 sub-196 sub-198 sub-199 sub-200sub-002 sub-010 sub-011 sub-012 sub-025 sub-026 sub-028 sub-039 sub-046 sub-052 sub-086 sub-091 sub-097 sub-098 sub-099 sub-100 sub-101 sub-102 sub-103 sub-103 sub-106 sub-111 sub-112 sub-116 sub-121 sub-125 sub-127 sub-131 sub-138 sub-144 sub-145 sub-147 sub-156 sub-157 sub-185 sub-186 sub-189 sub-190 sub-191sub-006 sub-015 sub-018 sub-021 sub-022 sub-024 sub-028 sub-030 sub-032 sub-036 sub-038 sub-048 sub-060 sub-064 sub-068 sub-079 sub-093 sub-109 sub-110 sub-121 sub-122 sub-123 sub-124 sub-125 sub-126 sub-127 sub-128 sub-129 sub-130 sub-131 sub-132 sub-133 sub-134 sub-135 sub-136 sub-137 sub-138 sub-139 sub-140 sub-160 sub-166 sub-197 sub-201sub-400 sub-401 sub-402 sub-403 sub-404 sub-405 sub-406 sub-407 sub-408 sub-409 sub-410 sub-411 sub-412 sub-413 sub-414 sub-415 sub-416 sub-417 sub-418 sub-419 sub-420 sub-421 sub-422 sub-423 sub-424 sub-425 sub-426 sub-427 sub-428 sub-430 sub-431 sub-432 sub-433 sub-434 sub-435 sub-436 sub-437 sub-438 sub-439 sub-440 sub-441 sub-442 sub-443 sub-444 sub-445 sub-446 sub-447 sub-448 sub-449 sub-450 sub-451 sub-452 sub-454 sub-455 sub-456 sub-457 sub-458 sub-459 sub-460 sub-461 sub-462 sub-463 sub-464 sub-465 sub-466 sub-467 sub-468 sub-469 sub-470 sub-471 sub-472 sub-473 sub-474 sub-475 sub-476 sub-477 sub-478 sub-479 sub-480 sub-481 sub-482 sub-483 sub-484 sub-485 sub-486 sub-487 sub-488 sub-489 sub-490 sub-491 sub-492 sub-493 sub-494 sub-495 sub-496 sub-497 sub-498 sub-499 sub-500 sub-501 sub-502 sub-503 sub-504 sub-505 sub-506 sub-507 sub-508 sub-509 sub-510 sub-511 sub-512 sub-513 sub-514 sub-515 sub-516 sub-517sub-701
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

# This script runs on the outputs from ICAFIX

######################################### DO WORK ##########################################

# List of fMRI runs
# If running on output from multi-run FIX, use ConcatName as value for fMRINames
fMRINames="task-rest_dir-RL_LR"

HighPass="0"
ReUseHighPass="YES" #Use YES if running on output from multi-run FIX, otherwise use NO

DualScene=${HCPPIPEDIR}/ICAFIX/PostFixScenes/ICA_Classification_DualScreenTemplate.scene
SingleScene=${HCPPIPEDIR}/ICAFIX/PostFixScenes/ICA_Classification_SingleScreenTemplate.scene

MatlabMode="0" #Mode=0 compiled Matlab, Mode=1 interpreted Matlab, Mode=2 octave

for Subject in $Subjlist ; do
  for fMRIName in ${fMRINames} ; do
	  echo "    ${Subject}"
	
	  if [ -n "${command_line_specified_run_local}" ] ; then
	      echo "About to run ${HCPPIPEDIR}/ICAFIX/PostFix.sh"
	      queuing_command=""
	  else
	      echo "About to use fsl_sub to queue or run ${HCPPIPEDIR}/ICAFIX/PostFix.sh"
	      queuing_command="${FSLDIR}/bin/fsl_sub ${QUEUE}"
	  fi

	  ${queuing_command} ${HCPPIPEDIR}/ICAFIX/PostFix.sh \
    --study-folder=${StudyFolder} \
    --subject=${Subject} \
    --fmri-name=${fMRIName} \
    --high-pass=${HighPass} \
    --template-scene-dual-screen=${DualScene} \
    --template-scene-single-screen=${SingleScene} \
    --reuse-high-pass=${ReUseHighPass} \
    --matlab-run-mode=${MatlabMode}
  done
done

