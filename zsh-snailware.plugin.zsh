# -*- mode: shell-script; -*-
#
# Copyright (C) 2012-2013 Xavier Garrido
#
# Author: garrido@lal.in2p3.fr
# Keywords: snailware, supernemo
# Requirements: pkgtools
# Status: not intended to be distributed yet

# Store current directory for further use
export SNAILWARE_GIT_DIR=$(dirname $0)

typeset -ga __bayeux_bundles
__bayeux_bundles=(
  datatools
  mygsl
  materials
  geomtools
  brio
  cuts
  genvtx
  trackfit
  emfield
  dpp
  genbb_help
  mctools
)
typeset -ga __channel_bundles
__channel_bundles=(
  TrackerPreClustering
  CellularAutomatonTracker
  TrackerClusterPath
)
typeset -ga __falaise_bundles
__falaise_bundles=(
  sngeometry
  sncore
  sngenvertex
  # sngenbb
  # sng4
  snreconstruction
  snvisualization
  snanalysis
  #    snelectronics
)
typeset -ga __chevreuse_bundles
__chevreuse_bundles=(
  matacqana
  bipoanalysis
  bipovisualization
)

# Aliases
alias snsource='snailware setup'
compdef _snailware sns=snailware
alias snconf='snailware configure'
compdef _snailware snc=snailware
alias snbuild='snailware build'
compdef _snailware snb=snailware
alias sninstall='snailware build'
compdef _snailware sni=snailware
alias snreset='snailware reset'
compdef _snailware snr=snailware
alias snup='snailware git-update'
compdef _snailware snu=snailware
alias sntest='snailware test'
compdef _snailware snt=snailware
alias snco='snailware git-checkout'
compdef _snailware snco=snailware
alias snpush='snailware git-push'
compdef _snailware snpush=snailware
alias sngoto='snailware goto'
compdef _snailware sngoto=snailware
alias snrebuild='snailware rebuild'
compdef _snailware snrebuild=snailware
alias snstatus='snailware status all'

function snailware ()
{
  __pkgtools__default_values
  __pkgtools__at_function_enter snailware

  local append_list_of_options_arg
  local append_list_of_components_arg
  local mode
  local with_test=0
  local with_doc=0
  local git_branch=

  while [ -n "$1" ]; do
    local token=$1
    if [ "${token[0,1]}" = "-" ]; then
      local opt=${token}
      append_list_of_options_arg+="${opt} "
      if [ "${opt}" = "-h" -o "${opt}" = "--help" ]; then
        return 0
      elif [ "${opt}" = "-d" -o "${opt}" = "--debug" ]; then
	pkgtools__msg_using_debug
      elif [ "${opt}" = "-D" -o "${opt}" = "--devel" ]; then
	pkgtools__msg_using_devel
      elif [ "${opt}" = "-v" -o "${opt}" = "--verbose" ]; then
	pkgtools__msg_using_verbose
      elif [ "${opt}" = "-W" -o "${opt}" = "--no-warning" ]; then
	pkgtools__msg_not_using_warning
      elif [ "${opt}" = "-q" -o "${opt}" = "--quiet" ]; then
	pkgtools__msg_using_quiet
	export PKGTOOLS_MSG_QUIET=1
      elif [ "${opt}" = "-i" -o "${opt}" = "--interactive" ]; then
	pkgtools__ui_interactive
      elif [ "${opt}" = "-b" -o "${opt}" = "--batch" ]; then
	pkgtools__ui_batch
      elif [ "${opt}" = "--gui" ]; then
	pkgtools__ui_using_gui
      elif [ "${opt}" = "--with-test" ]; then
	with_test=1
      elif [ "${opt}" = "--without-test" ]; then
	with_test=0
      elif [ "${opt}" = "--with-doc" ]; then
	with_doc=1
      elif [ "${opt}" = "--without-doc" ]; then
	with_doc=0
      elif [ "${opt}" = "--branch" ]; then
        shift 1
	git_branch=$1
        append_list_of_options_arg+="${git_branch} "
      fi
    else
      if [ "${token}" = "environment" ]; then
        mode="environment"
      elif [ "${token}" = "configure" ]; then
        mode="configure"
      elif [ "${token}" = "build" ]; then
        mode="build"
      elif [ "${token}" = "rebuild" ]; then
        mode="rebuild"
      elif [ "${token}" = "reset" ]; then
        mode="reset"
      elif [ "${token}" = "svn-update" ]; then
        mode="svn-update"
      elif [ "${token}" = "setup" ]; then
        mode="setup"
      elif [ "${token}" = "test" ]; then
        mode="test"
      elif [ "${token}" = "status" ]; then
        mode="status"
      elif [ "${token}" = "git-checkout" ]; then
        mode="git-checkout"
      elif [ "${token}" = "git-update" ]; then
        mode="git-update"
      elif [ "${token}" = "git-branch" ]; then
        mode="git-branch"
      elif [ "${token}" = "git-push" ]; then
        mode="git-push"
      elif [ "${token}" = "goto" ]; then
        mode="goto"
      elif [ "${token}" = "complete" ]; then
        mode="complete"
      else
	arg=${token}
	if [ "x${arg}" != "x" ]; then
	  append_list_of_components_arg+="${arg} "
	fi
      fi
    fi
    shift 1
  done

  pkgtools__msg_devel "mode=${mode}"
  pkgtools__msg_devel "append_list_of_components_arg=${append_list_of_components_arg}"
  pkgtools__msg_devel "append_list_of_options_arg=${append_list_of_options_arg}"
  pkgtools__msg_devel "with_test=${with_test}"
  pkgtools__msg_devel "with_doc=${with_doc}"
  pkgtools__msg_devel "git_branch=${git_branch}"

  # Remove last space
  append_list_of_components_arg=${append_list_of_components_arg%?}
  append_list_of_options_arg=${append_list_of_options_arg%?}

  # Move into an array
  append_list_of_components_arg=($(echo ${append_list_of_components_arg}))
  append_list_of_options_arg=($(echo ${append_list_of_options_arg}))

  # Setting environment
  if [ ${mode} = environment ]; then
    __snailware_environment
    __pkgtools__at_function_exit
    return 0
  else
    if [ ! -n "${SNAILWARE_SETUP_DONE}" ];then
      pkgtools__msg_warning "Setting default environment"
      __snailware_environment
    fi
  fi

  # Development status
  if [ ${mode} = status ]; then
    __snailware_status ${append_list_of_components_arg}
    __pkgtools__at_function_exit
    return 0
  fi

  # Lookup
  for icompo in ${=append_list_of_components_arg}
  do
    if [ ${icompo} = all ]; then
      snailware ${append_list_of_options_arg} ${mode} ${__aggregator_bundles}
      continue
    elif [ ${icompo} = cadfael ]; then
      continue
    elif [ ${icompo} = bayeux ]; then
      snailware ${append_list_of_options_arg} ${mode} ${__bayeux_bundles}
      continue
    elif [ ${icompo} = channel ]; then
      snailware ${append_list_of_options_arg} ${mode} ${__channel_bundles}
      continue
    elif [ ${icompo} = falaise ]; then
      snailware ${append_list_of_options_arg} ${mode} ${__falaise_bundles}
      continue
    elif [ ${icompo} = chevreuse ]; then
      snailware ${append_list_of_options_arg} ${mode} ${__chevreuse_bundles}
      continue
    fi

    if [[ ${mode} = svn-checkout || ${mode} = git-checkout ]]; then
      pkgtools__msg_notice "Checking out '${icompo}' component"
      local svn_path="https://nemo.lpc-caen.in2p3.fr/svn"
      local aggregator="none"
      if [[ ${__bayeux_bundles[(i)${icompo}]} -le ${#__bayeux_bundles} ]]; then
        svn_path+="/${icompo}"
        aggregator="bayeux"
      elif [[ ${__channel_bundles[(i)${icompo}]} -le ${#__channel_bundles} ]]; then
        svn_path+="/snsw/devel/Channel/Components/${icompo}"
        aggregator="channel"
      elif [[ ${__falaise_bundles[(i)${icompo}]} -le ${#__falaise_bundles} ]]; then
        svn_path+="/snsw/devel/${icompo}"
        aggregator="falaise"
      elif [[ ${__chevreuse_bundles[(i)${icompo}]} -le ${#__chevreuse_bundles} ]]; then
        aggregator="chevreuse"
        case ${icompo} in
          matacqana)
            svn_path+="/${icompo}";;
          bipoanalysis)
            svn_path+="/snsw/devel/${icompo}";;
          bipovisualization)
            svn_path+="/snsw/misc/${icompo}";;
        esac
      fi

      if [ ${mode} = git-checkout ]; then
        if [ ! -d ${SNAILWARE_DEV_DIR}/${aggregator}/${icompo} ]; then
          mkdir -p ${SNAILWARE_DEV_DIR}/${aggregator}/${icompo}
        fi
        (
          cd ${SNAILWARE_DEV_DIR}/${aggregator}/${icompo}
          if (( $+commands[go-svn2git] )); then
            go-svn2git -username garrido -verbose ${svn_path}
          else
            git svn init --prefix=svn/ --username=garrido   \
              --trunk=trunk --tags=tags --branches=branches \
              ${svn_path}
            git svn fetch
            git branch -l --no-color
            for branch in $(git branch -r --no-color)
            do
              if [[ $branch == *svn/tags* ]]; then
                subject=$(git log -1 --pretty=format:%s $branch)
                new_branch=${branch/svn\/tags\/}
                git tag -a -m \"$subject\" $new_branch $branch
                git branch -d -r $branch
              else
                new_branch=${branch/svn\/}
                if [ $new_branch != trunk ]; then
                  git branch ${new_branch} remotes/$branch
                  git checkout $new_branch
                fi
              fi
            done
            git checkout -f master
            git gc
          fi
        )
      fi
      continue
    fi

    # Look for the corresponding directory
    local is_found=0
    for i in ${__aggregator_bundles}
    do
      pushd ${SNAILWARE_DEV_DIR}/$i/${icompo} > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        is_found=1
        break
      fi
    done

    if [ ${is_found} -eq 0 ]; then
      pkgtools__msg_error "Development directory of '${icompo}' does not exist!"
      continue
    elif [ ${mode} = goto ]; then
      __pkgtools__at_function_exit
      return 0
    fi
    unset is_found

    local tmp_dir=/tmp/${USER}
    if [ ! -d ${tmp_dir} ]; then mkdir ${tmp_dir}; fi
    local tmp_file_name=${tmp_dir}/${icompo}_dev.log
    if [ -f ${tmp_file_name} ]; then rm -rf ${tmp_file_name}; fi

    case ${mode} in
      git-update)
        pkgtools__msg_notice "Updating '${icompo}' component"
        git svn fetch
        git svn rebase
        if [ $? -ne 0 ]; then
          pkgtools__msg_error "Updating '${icompo}' component fails !"
          break
        fi
        ;;
      git-push)
        pkgtools__msg_notice "Pushing '${icompo}' component"
        git svn dcommit
        if [ $? -ne 0 ]; then
          pkgtools__msg_error "Pushing '${icompo}' component fails !"
          break
        fi
        ;;
      git-branch)
        pkgtools__msg_notice "Changing git branch to '${git_branch}' for '${icompo}' component"
        git checkout ${git_branch} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          export __${icompo}_dev_branch=${git_branch}
        else
          pkgtools__msg_error "Changing git branch for '${icompo}' component fails !"
          break
        fi
        ;;
      setup)
        pkgtools__msg_notice "Sourcing '${icompo}' component"
        if [[ ${__aggregator_bundles[(i)${icompo}]} -le ${#__aggregator_bundles} ]]; then
          snailware::source_${icompo}
        else
          local dcompo=$(echo ${icompo} | tr '[A-Z]' '[a-z]')
          local test_env=$(eval "echo \$$(echo __${icompo}_dev_setup)")
          if [ -n "${test_env}" ]; then
            pkgtools__msg_warning "Component '${icompo}' has been already setup"
            continue
          fi
          source __instal*/etc/${dcompo}_setup.sh > ${tmp_file_name} 2>&1
          if [ $? -eq 0 ]; then
            do_${dcompo}_setup
            export __${icompo}_dev_setup=1
          else
            pkgtools__msg_warning "Sourcing '${icompo}' component fails !"
            #break
          fi
        fi
        ;;
      configure)
        pkgtools__msg_notice "Configuring '${icompo}' component"
        local configure_option
        if [ ${with_test} -eq 0 ]; then
          configure_option+="--without-test "
        else
          configure_option+="--with-test "
        fi
        if [ ${with_doc} -eq 0 ]; then
          configure_option+="--without-documentation "
        else
          configure_option+="--with-documentation "
        fi
        pkgtools__msg_devel "configure_option=${configure_option}"
        ./pkgtools.d/pkgtool configure ${configure_option}
        if [ $? -ne 0 ]; then
          pkgtools__msg_error "Configuring '${icompo}' component fails !"
          [[ -f ".${icompo}_dev_configure" ]] && rm ".${icompo}_dev_configure"
          break
        else
          touch ".${icompo}_dev_configure"
        fi
        unset configure_option
        ;;
      build)
        pkgtools__msg_notice "Building '${icompo}' component"
        ./pkgtools.d/pkgtool install
        if [ $? -ne 0 ]; then
          pkgtools__msg_error "Building '${icompo}' component fails !"
          [[ -f ".${icompo}_dev_install" ]] && rm ".${icompo}_dev_install"
          break
        else
          touch ".${icompo}_dev_install"
          [[ -f ".${icompo}_dev_tested" ]] && rm ".${icompo}_dev_tested"
        fi
        ;;
      reset)
        pkgtools__msg_notice "Reseting '${icompo}' component"
        echo "y" | ./pkgtools.d/pkgtool reset
        if [ $? -ne 0 ]; then
          pkgtools__msg_error "Reseting '${icompo}' component fails !"
          break
        else
          test -f ".${icompo}_dev_setup"      && rm ".${icompo}_dev_setup"
          test -f ".${icompo}_dev_install"    && rm ".${icompo}_dev_install"
          test -f ".${icompo}_dev_configure"  && rm ".${icompo}_dev_configure"
          test -f ".${icompo}_dev_tested"     && rm ".${icompo}_dev_tested"
          touch __stupid_thing
          dirs=(ls __*)
          for dir in $dirs
          do
            rm -rf "$dir"
          done
        fi
        ;;
      rebuild)
        pkgtools__msg_notice "Rebuilding '${icompo}' component"
        snailware ${append_list_of_options_arg} reset     ${icompo}
        snailware ${append_list_of_options_arg} configure ${icompo}
        snailware ${append_list_of_options_arg} build     ${icompo}
        snailware ${append_list_of_options_arg} setup     ${icompo}
        ;;
      test)
        pkgtools__msg_notice "Testing '${icompo}' component"
        ./pkgtools.d/pkgtool test
        if [ $? -ne 0 ]; then
          pkgtools__msg_error "Testing '${icompo}' component fails !"
          [[ -f ".${icompo}_dev_tested" ]] && rm ".${icompo}_dev_tested"
          break
        else
          touch ".${icompo}_dev_tested"
        fi
        ;;
      complete)
        __snailware_complete
        if [ $? -ne 0 ]; then
          pkgtools__msg_error "Something when build completion for '${icompo}' programs !"
          break
        fi
        ;;
    esac

    popd > /dev/null 2>&1
  done

  unset tmp_dir tmp_file_name
  unset with_test with_doc
  unset mode append_list_of_components_arg append_list_of_options_arg

  __pkgtools__at_function_exit
  return 0
}

# Private functions suppose not to be called interactively
function __snailware_environment ()
{
  __pkgtools__at_function_enter __snailware_environment

  if [ -n "${SNAILWARE_SETUP_DONE}" ]; then
    __pkgtools__at_function_exit
    return 0
  fi
  export SNAILWARE_SETUP_DONE=1

  # Take care of running machine
  case "${HOSTNAME}" in
    garrido-laptop)
      nemo_base_dir_tmp="/home/${USER}/Workdir/NEMO"
      nemo_pro_dir_tmp="${nemo_base_dir_tmp}/supernemo/snware"
      nemo_dev_dir_tmp="${nemo_base_dir_tmp}/supernemo/development"
      nemo_simulation_dir_tmp="${nemo_base_dir_tmp}/supernemo/simulations"
      ;;
    pc-91089)
      nemo_base_dir_tmp="/data/workdir/nemo/"
      nemo_pro_dir_tmp="${nemo_base_dir_tmp}/supernemo/snware"
      nemo_dev_dir_tmp="${nemo_base_dir_tmp}/supernemo/development"
      nemo_simulation_dir_tmp="${nemo_base_dir_tmp}/supernemo/simulations"
      ;;
    lx3.lal.in2p3.fr|nemo*.lal.in2p3.fr)
      nemo_base_dir_tmp="/exp/nemo/snsw"
      nemo_pro_dir_tmp="${nemo_base_dir_tmp}/supernemo/snware"
      nemo_dev_dir_tmp="/exp/nemo/${USER}/workdir/supernemo/development"
      nemo_simulation_dir_tmp="/scratch/${USER}/simulations"
      cadfael_version="0.1.0"
      ;;
    ccige*|ccage*)
      nemo_base_dir_tmp="/afs/in2p3.fr/group/nemo"
      nemo_pro_dir_tmp="${nemo_base_dir_tmp}/sw2"
      nemo_dev_dir_tmp="/sps/nemo/scratch/${USER}/workdir/supernemo/development"
      nemo_simulation_dir_tmp="/sps/nemo/scratch/${USER}/simulations"
      cadfael_version="0.2.1"
      cadfael_setup_file="${nemo_pro_dir_tmp}/Cadfael/Cadfael-${cadfael_version}/Install/etc/cadfael_setup.sh"
      ;;
    *)
      nemo_base_dir_tmp="/home/${USER}/Workdir"
      nemo_pro_dir_tmp="${nemo_base_dir_tmp}/supernemo/snware"
      nemo_dev_dir_tmp="${nemo_base_dir_tmp}/supernemo/development"
      ;;
  esac

  pkgtools__set_variable SNAILWARE_BASE_DIR       "${nemo_base_dir_tmp}"
  pkgtools__set_variable SNAILWARE_PRO_DIR        "${nemo_pro_dir_tmp}"
  pkgtools__set_variable SNAILWARE_DEV_DIR        "${nemo_dev_dir_tmp}"
  pkgtools__set_variable SNAILWARE_SIMULATION_DIR "${nemo_simulation_dir_tmp}"

  # Export main env. variables
  which ccache > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    export CXX="ccache g++"
    export CC="ccache gcc"
  fi

  __pkgtools__at_function_exit
  return 0
}

function __snailware_status ()
{
  __pkgtools__at_function_enter __snailware_status

  for icompo in ${=@}
  do
    if [ "${icompo}" = "all" ]; then
      __snailware_status bayeux channel falaise chevreuse
      continue
    elif [ "${icompo}" = "falaise" ]; then
      echo
      echo -n "$fg_bold[blue]"
      printf ' %15s %6s %6s %6s %6s %6s\n' falaise status source config. install tested
      __snailware_status sngeometry sncore sngenvertex sngenbb sng4 snreconstruction snvisualization snanalysis
      continue
    elif [ "${icompo}" = "bayeux" ]; then
      echo
      echo -n "$fg_bold[red]"
      printf ' %15s %6s %6s %6s %6s %6s\n' bayeux status source config. install tested
      __snailware_status datatools brio cuts mygsl geomtools genbb_help genvtx materials trackfit
      continue
    elif [ "${icompo}" = "channel" ]; then
      echo
      echo -n "$fg_bold[green]"
      printf ' %15s %6s %6s %6s %6s %6s\n' channel status source config. install tested
      __snailware_status TrackerPreClustering CellularAutomatonTracker TrackerClusterPath
      continue
    elif [ "${icompo}" = "chevreuse" ]; then
      echo
      echo -n "$fg_bold[magenta]"
      printf ' %15s %6s %6s %6s %6s %6s\n' chevreuse status source config. install tested
      __snailware_status matacqana bipoanalysis bipovisualization
      continue
    fi

    echo -n "${reset_color}"
    printf ' %15s' ${icompo[1,15]}

    local is_found=0
    directory_list=(bayeux channel falaise chevreuse)
    for i in ${directory_list}
    do
      pushd ${SNAILWARE_DEV_DIR}/$i/${icompo} > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        is_found=1
        break
      fi
    done
    unset directory_list

    if [ ${is_found} -eq 0 ]; then
      echo -n "$fg[red]"
      printf ' %7s %7s %7s %7s %7s' ¤ ¤ ¤ ¤ ¤
    else
      local svn_status=
      if [ -d .git ]; then
        svn_status=$(git diff --name-status svn/trunk)
        if [ "${svn_status}" != "" ]; then
          svn_status="no"
        fi
      else
        svn_status=$(svn_dirty_choose no ok)
      fi
      if [ "$svn_status" = "no" ]; then
        echo -n "$fg[red]"
        printf ' %4s' ✘
        # printf "  "
      else
        echo -n "$fg[green]"
        printf ' %4s' ✔
        # printf " "
      fi
      echo -n "${reset_color}"

      local test_env=$(eval "echo \$$(echo __${icompo}_dev_setup)")
      if [ -n "${test_env}" ]; then
        echo -n "$fg[green]"
        printf ' %6s' ✔
      else
        echo -n "$fg[red]"
        printf ' %6s' ✘
      fi
      echo -n "${reset_color}"

      str_list=(configure install tested)
      for i in ${str_list}
      do
        local file_test=".${icompo}_dev_$i"
        if [ -f "${file_test}" ]; then
          echo -n "$fg[green]"
          printf ' %6s' ✔
        else
          echo -n "$fg[red]"
          printf ' %6s' ✘
        fi
        echo -n "${reset_color}"
      done
    fi

    popd > /dev/null 2>&1
    echo -n "${reset_color}\n"
  done

  unset is_found
  unset icompo

  __pkgtools__at_function_exit
  return 0
}

function __snailware_complete ()
{
  __pkgtools__at_function_enter __snailware-complete

  # Internal function to stream 'echo' command
  __parse ()
  {
    local find_begin_description=0
    local find_end_description=1
    local data_type=""
    for token in $(sed -n '/add_options/,/;/p' $1)
    do
      if [[ "$token" == *';'* ]]; then
        break
      fi
      token=${token/\\n/ }
      pkgtools__msg_devel "token = ${token}"
      if [[ "$token" == *'"'* ]]; then
        # Get option indentificator
        if [[ "$token" == *'("'* ]]; then
          if [[ "$token" == *'")'* ]]; then
            continue
          fi
          if [ ${find_end_description} -eq 0 ]; then
            data_type=""
            find_end_description=1
            find_begin_description=0
            echo "]' \\"

          fi
          local tmp=$(echo ${token%?} | sed 's/[("\]//g')
          local opt1=$(echo $tmp | cut -d',' -f1)
          local opt2=$(echo $tmp | cut -d',' -f2)
          if [ ${#opt1} = ${#opt2} ]; then
            test ${#opt1} -gt 1 && echo -ne "--${opt1}"
          elif [ ${#opt1} -gt ${#opt2} ]; then
            echo -ne "{-${opt2},--${opt1}}"
          else
            echo -ne "{-${opt1},--${opt2}}"
          fi
        elif [[ "$token" == *'")'* ]]; then
          token=$(echo ${token} | sed 's/[."]//g')
          if [ ${find_begin_description} -eq 1 ]; then
            data_type=""
            find_end_description=1
            find_begin_description=0
            echo "${token%)}${data_type}]' \\"
          fi
        else
          token=$(echo ${token} | sed 's/["\\]//g')
          if [ ${find_end_description} -eq 1 ]; then
            find_end_description=0
            find_begin_description=1
            echo -ne "'[${token#\"} "
          else
            echo -ne "${token} "
          fi
        fi
      elif [[ "$token" != *'->'* ]]; then
        if [[ ${find_begin_description} -eq 1 && ${find_end_description} -eq 0 ]]; then
          if [ "$token" != ")" ]; then
            token=$(echo ${token} | sed 's/[;"\\]//g')
            echo -ne "${token} "
          fi
          # elif [[ "${token}" == *"::value<"* ]]; then
          #     tmp=${token##*value<}
          #     tmp=${tmp%%>*}
          #     if [ "${tmp}" == "bool" ];then
          #         data_type=":boolean:(true false)"
          #     elif [ "${tmp}" == "int" ]; then
          #         data_type=":number"
          #     elif [ "${tmp}" == "double" ]; then
          #         data_type=":number"
          #     fi
        fi
      fi
    done
    if [ ${find_end_description} -eq 0 ]; then
      echo "]' \\"
    fi
    unset token
    unset find_begin_description find_end_description
    unset data_type
  }

  excluded_programs=(ocd_manual snemo_event_browser snemo_non_gui_browser)
  for program_file in $(find $PWD/programs -name "*.cxx" 2>/dev/null)
  do
    local program_name=$(basename ${program_file%.cxx})
    if [[ ${excluded_programs[(i)${program_name}]} -le ${#excluded_programs} ]]; then
      pkgtools__msg_debug "Program ${program_name} is excluded"
      continue
    fi

    local completion_file=${SNAILWARE_GIT_DIR}/_${program_name}
    cat ${program_file} | grep -q add_options
    if [ $? -ne 0 ]; then
      pkgtools__msg_debug "Program ${program_name} from '${icompo}' component does not use boost::program_option ! Skip it !"
      continue
    else
      pkgtools__msg_notice "Build completion system for program ${program_name} from '${icompo}' component"
    fi

    cat << EOF > ${completion_file}
#compdef ${program_name}

function _${program_name} ()
{
  typeset -A opt_args
  local context state line curcontext="$curcontext"

  _arguments \\
EOF
    __parse ${program_file} >> ${completion_file}
    cat << EOF >> ${completion_file}
'*: :->args' \\
&& ret=0

  case \$state in
    args)
      _files -/
      ;;
  esac

  return ret
}

_${program_name} "\$@"


# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
EOF
  done

  __pkgtools__at_function_exit
  return 0
}
# end
