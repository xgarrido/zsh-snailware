# -*- mode: shell-script; -*-

# Copyright (C) 2012 Xavier Garrido
#
# Author: garrido@lal.in2p3.fr
# Keywords: snailware, supernemo
# Requirements: pkgtools
# Status: not intended to be distributed yet

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
alias snup='snailware svn-update'
compdef _snailware snu=snailware
alias sntest='snailware test'
compdef _snailware snt=snailware
alias snst='snailware svn-status'
compdef _snailware snst=snailware
alias sndiff='snailware svn-diff'
compdef _snailware sndiff=snailware
alias snco='snailware svn-checkout'
compdef _snailware snco=snailware
alias sngoto='snailware goto'
compdef _snailware sngoto=snailware
alias snrebuild='snailware rebuild'
compdef _snailware snrebuild=snailware
alias snstatus='snailware status all'

function snailware ()
{
    __pkgtools__at_function_enter snailware
    if [ ! -n "${SNAILWARE_SETUP_DONE}" ];then
        pkgtools__msg_error "SN@ilWare setup is not defined ! Components will not be built!"
        __pkgtools__at_function_exit
        return 1
    fi

    local mode
    local append_list_of_options_arg
    local append_list_of_components_arg
    local with_test=1
    local with_doc=0

    while [ -n "$1" ]; do
        local token="$1"
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
           fi
        else
            if [ "${token}" = "configure" ]; then
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
            elif [ "${token}" = "svn-diff" ]; then
                mode="svn-diff"
            elif [ "${token}" = "svn-status" ]; then
                mode="svn-status"
            elif [ "${token}" = "svn-checkout" ]; then
                mode="svn-checkout"
            elif [ "${token}" = "goto" ]; then
                mode="goto"
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
    pkgtools__msg_devel "version=${version}"
    pkgtools__msg_devel "append_list_of_components_arg=${append_list_of_components_arg}"
    pkgtools__msg_devel "append_list_of_options_arg=${append_list_of_options_arg}"
    pkgtools__msg_devel "with_test=${with_test}"
    pkgtools__msg_devel "with_doc=${with_doc}"

    # Remove last space
    append_list_of_components_arg=${append_list_of_components_arg%?}
    append_list_of_options_arg=${append_list_of_options_arg%?}

    if [ "${mode}" = "status" ]; then
        __snailware_status ${append_list_of_components_arg}
        __pkgtools__at_function_exit
        return 0
    fi

    if [ "${mode}" = "rebuild" ]; then
        __snailware_rebuild ${append_list_of_components_arg}
        __pkgtools__at_function_exit
        return 0
    fi

    for icompo in ${=append_list_of_components_arg}
    do
        if [ "${icompo}" = "all" ]; then
            snailware ${append_list_of_options_arg} ${mode} bayeux channel falaise
            continue
        elif [ "${icompo}" = "bayeux" ]; then
            snailware ${append_list_of_options_arg} ${mode} \
                datatools  \
                brio       \
                cuts       \
                mygsl      \
                geomtools  \
                genbb_help \
                genvtx     \
                materials  \
                trackfit
            continue
        elif [ "${icompo}" = "channel" ]; then
            snailware ${append_list_of_options_arg} ${mode} \
                TrackerPreClustering     \
                CellularAutomatonTracker \
                TrackerClusterPath
            continue
        elif [ "${icompo}" = "falaise" ]; then
            snailware ${append_list_of_options_arg} ${mode} \
                sngeometry       \
                sncore           \
                sngenvertex      \
                sngenbb          \
                sng4             \
                snreconstruction \
                snvisualization  \
                snanalysis
            continue
        elif [ "${icompo}" = "extra" ]; then
            snailware ${append_list_of_options_arg} ${mode} \
                matacqana    \
                bipoanalysis \
                bipovisualization
            continue
        fi

        local version="${SNAILWARE_SOFTWARE_VERSION}"
        case "${icompo}" in
            snutils|sngeometry|sncore|sngenvertex|sngenbb|sng4|snreconstruction|snvisualization|snanalysis)
                version="branches/dev0"
                pkgtools__msg_warning "Temporary fix for Falaise component : force the use of ${version} version"
                ;;
        esac

        if [ "${mode}" = "svn-checkout" ]; then
            pkgtools__msg_notice "Checking out '${icompo}' component"
            case "${icompo}" in
                datatools|brio|cuts|mygsl|geomtools|genbb_help|genvtx|materials|trackfit|matacqana)
                    svn co https://nemo.lpc-caen.in2p3.fr/svn/${icompo}/${version} \
                        ${SNAILWARE_DEV_DIR}/bayeux/${version}/${icompo}
                    ;;
                TrackerPreClustering|CellularAutomatonTracker|TrackerClusterPath)
                    svn co https://nemo.lpc-caen.in2p3.fr/svn/snsw/devel/Channel/Components/${icompo}/${version} \
                        ${SNAILWARE_DEV_DIR}/channel/${version}/${icompo}
                    ;;
                snutils|sngeometry|sncore|sngenvertex|sngenbb|sng4|snreconstruction|snvisualization|snanalysis)
                    svn co https://nemo.lpc-caen.in2p3.fr/svn/snsw/devel/${icompo}/${version} \
                        ${SNAILWARE_DEV_DIR}/falaise/${version}/${icompo}
                    ;;
            esac
          continue
        fi

        local is_found=0
        directory_list=(bayeux channel falaise)
        for i in ${directory_list}
        do
            pushd ${SNAILWARE_DEV_DIR}/$i/${version}/${icompo} > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                is_found=1
                break
            fi
        done
        unset version

        if [ ${is_found} -eq 0 ]; then
            pkgtools__msg_error "Development directory of '${icompo}' does not exist!"
            continue
        elif [ "${mode}" = "goto" ]; then
            __pkgtools__at_function_exit
            return 0
        fi
        unset is_found

        local tmp_dir=/tmp/${USER}
        if [ ! -d ${tmp_dir} ]; then mkdir ${tmp_dir}; fi
        local tmp_file_name=${tmp_dir}/${icompo}_dev.log
        if [ -f ${tmp_file_name} ]; then rm -rf ${tmp_file_name}; fi

        case "${mode}" in
            svn-update)
                pkgtools__msg_notice "Updating '${icompo}' component"
                svn up
                if [ $? -ne 0 ]; then
                    pkgtools__msg_error "Updating '${icompo}' component fails !"
                    break
                fi
                ;;
            setup)
                pkgtools__msg_notice "Sourcing '${icompo}' component"
                local dcompo=$(echo ${icompo} | tr '[A-Z]' '[a-z]')
                local test_env=$(eval "echo \$$(echo __${icompo}_dev_setup)")
                if [ -n "${test_env}" ]; then
                    pkgtools__msg_error "Component '${icompo}' has been already setup"
                    continue
                fi

                source __instal*/etc/${dcompo}_setup.sh > ${tmp_file_name} 2>&1
                if [ $? -eq 0 ]; then
                    do_${dcompo}_setup
                    export __${icompo}_dev_setup=1
                else
                    pkgtools__msg_error "Sourcing '${icompo}' component fails !"
                    break
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
                    [[ -f ".${icompo}_dev_setup" ]]     && rm ".${icompo}_dev_setup"
                    [[ -f ".${icompo}_dev_install" ]]   && rm ".${icompo}_dev_install"
                    [[ -f ".${icompo}_dev_configure" ]] && rm ".${icompo}_dev_configure"
                    [[ -f ".${icompo}_dev_tested" ]]    && rm ".${icompo}_dev_tested"
                    [[ -f "__build-*" ]]   && rm -rf "__build-*"
                    [[ -f "__install-*" ]] && rm -rf "__install-*"
                fi
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
            svn-status)
                pkgtools__msg_notice "SVN status '${icompo}' component"
                svnstatus
                ;;
            svn-diff)
                pkgtools__msg_notice "SVN diff '${icompo}' component"
                svndiff
                ;;
        esac

        popd > /dev/null 2>&1
    done

    unset with_test with_doc
    unset mode append_list_of_components_arg append_list_of_options_arg

    __pkgtools__at_function_exit
    return 0
}

function __snailware_status ()
{
    __pkgtools__at_function_enter __snailware_status

    for icompo in ${=@}
    do
        if [ "${icompo}" = "all" ]; then
            __snailware_status bayeux channel falaise
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
        elif [ "${icompo}" = "extra" ]; then
            echo
            echo -n "$fg_bold[magenta]"
            printf ' %15s %6s %6s %6s %6s %6s\n' extra status source config. install tested
            __snailware_status matacqana bipoanalysis bipovisualization
            continue
        fi

        echo -n "${reset_color}"
        printf ' %15s' ${icompo[1,15]}

        local is_found=0
        directory_list=(bayeux channel falaise)
        for i in ${directory_list}
        do
            pushd ${SNAILWARE_DEV_DIR}/$i/${icompo} > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                is_found=1
                break
            fi
        done

        if [ ${is_found} -eq 0 ]; then
            echo -n "$fg[red]"
            printf ' %7s %7s %7s %7s %7s' ¤ ¤ ¤ ¤ ¤
        else
            local svn_status=$(svn_dirty_choose no ok)
            if [ "$svn_status" = "no" ]; then
                echo -n "$fg[red]"
                printf ' %4s' ✘
                # printf "  "
            else
                echo -n "$fg[green]"
                printf ' %4s' 
                # printf " "
            fi
            echo -n "${reset_color}"

            local test_env=$(eval "echo \$$(echo __${icompo}_dev_setup)")
            if [ -n "${test_env}" ]; then
                echo -n "$fg[green]"
                printf ' %6s' 
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
                    printf ' %6s' 
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

    unset icompo

    __pkgtools__at_function_exit
    return 0
}

function __snailware_rebuild ()
{
    __pkgtools__at_function_enter __snailware_rebuild

    if [ "$1" = "bayeux" ]; then
        pkgtools__msg_notice "Rebuilding Bayeux component chain"
        snreset  bayeux
        snconf   datatools
        snbuild  datatools
        snsource datatools
        snconf   mygsl
        snbuild  mygsl
        snsource mygsl
        snconf   geomtools
        snbuild  geomtools
        snsource geomtools
        snconf   bayeux
        snbuild  bayeux
        snsource bayeux
    elif [ "$1" = "channel" ]; then
        pkgtools__msg_notice "Rebuilding Channel component chain"
        snreset  channel
        snconf   channel
        snbuild  channel
        snsource channel
    elif [ "$1" = "falaise" ]; then
        pkgtools__msg_notice "Rebuilding Falaise component chain"
        snreset  falaise
        snconf   sngeometry
        snbuild  sngeometry
        snsource sngeometry
        snconf   sncore
        snbuild  sncore
        snsource sncore
        snconf   sngenvertex sngenbb
        snbuild  sngenvertex sngenbb
        snsource sngenvertex sngenbb
        snconf   falaise
        snbuild  falaise
        snsource falaise
    else
        pkgtools__msg_notice "Rebuilding '$1' component"
        snreset $1
        snconf  $1
        snbuild $1
    fi

    __pkgtools__at_function_exit
    return 0
}

# end