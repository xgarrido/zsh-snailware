# -*- mode: shell-script; -*-

function do_nemo_bash_setup ()
{
    local tmp_dir=/tmp/${USER}
    if [ ! -d ${tmp_dir} ]; then mkdir -p ${tmp_dir}; fi
    local tmp_file_name=${tmp_dir}/bash.log
    if [ -f ${tmp_file_name} ]; then rm ${tmp_file_name}; fi

    local set_notification=0

    local nemo_base_dir_tmp=
    local nemo_dev_dir_tmp=
    local nemo_pro_dir_tmp=
    local nemo_simulation_dir_tmp=

    # CMake package
    local cadfael_setup_file=
    local bayeux_setup_file=
    local falaise_setup_file=
    local channel_setup_file=

    local cadfael_version="trunk"
    local bayeux_version="trunk"
    local falaise_version="trunk"
    local channel_version="trunk"

    # Take car of running machine
    case "${HOSTNAME}" in
        garrido-laptop)
            nemo_base_dir_tmp="/home/garrido/Workdir/NEMO"
            nemo_pro_dir_tmp="${nemo_base_dir_tmp}/supernemo/snware"
            nemo_dev_dir_tmp="${nemo_base_dir_tmp}/supernemo/development"
            nemo_simulation_dir_tmp="${nemo_base_dir_tmp}/supernemo/simulations"
            set_notification=1
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
            nemo_dev_dir_tmp="/exp/nemo/garrido/workdir/supernemo/development"
            nemo_simulation_dir_tmp="/scratch/garrido/simulations"
            cadfael_version="0.1.0"
            ;;
        ccige*|ccage*)
            nemo_base_dir_tmp="/afs/in2p3.fr/group/nemo"
            nemo_pro_dir_tmp="${nemo_base_dir_tmp}/sw2"
            nemo_dev_dir_tmp="/sps/nemo/scratch/garrido/workdir/supernemo/development"
            nemo_simulation_dir_tmp="/sps/nemo/scratch/garrido/simulations"
            cadfael_version="0.2.1"
            cadfael_setup_file="${nemo_pro_dir_tmp}/Cadfael/Cadfael-${cadfael_version}/Install/etc/cadfael_setup.sh"
            ;;
        *)
            nemo_base_dir_tmp="/home/${USER}/Workdir"
            nemo_pro_dir_tmp="${nemo_base_dir_tmp}/supernemo/snware"
            nemo_dev_dir_tmp="${nemo_base_dir_tmp}/supernemo/development"
            ;;
    esac

    # Export main env. variables
    which ccache > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        export CXX="ccache g++"
        export CC="ccache gcc"
    fi
    export SNAILWARE_BASE_DIR="${nemo_base_dir_tmp}"
    export SNAILWARE_PRO_DIR="${nemo_pro_dir_tmp}"
    export SNAILWARE_DEV_DIR="${nemo_dev_dir_tmp}"
    export SNSW_SIMULATION_DIR="${nemo_simulation_dir_tmp}"

    # Build default setup file path
    [[ -z ${cadfael_setup_file} ]] && cadfael_setup_file="${SNAILWARE_PRO_DIR}/cadfael/install/${cadfael_version}/etc/cadfael_setup.sh"
    [[ -z ${bayeux_setup_file}  ]] && bayeux_setup_file="${SNAILWARE_PRO_DIR}/bayeux/install/${bayeux_version}/etc/bayeux_setup.sh"
    [[ -z ${falaise_setup_file} ]] && falaise_setup_file="${SNAILWARE_PRO_DIR}/falaise/install/${falaise_version}/etc/falaise_setup.sh"
    [[ -z ${channel_setup_file} ]] && channel_setup_file="${SNAILWARE_PRO_DIR}/channel/install/${channel_version}/etc/channel_setup.sh"

    # pkgtools
    local nemo_tool_base_dir="${SNAILWARE_BASE_DIR}/tools"
    if [ -f ${nemo_tool_base_dir}/pkgtools/pkgtools.sh ]; then
        source ${nemo_tool_base_dir}/pkgtools/pkgtools.sh
    fi

    # MakePackage
    export MAKEPACKAGE_INSTALL_PREFIX=${nemo_tool_base_dir}/make_package/install
    export PATH=${MAKEPACKAGE_INSTALL_PREFIX}/bin:${PATH}
    if [ -f ${MAKEPACKAGE_INSTALL_PREFIX}/etc/make_package.conf ]; then
        source ${MAKEPACKAGE_INSTALL_PREFIX}/etc/make_package.conf
    fi

    # MakeMemo
    export MAKEMEMO_ROOT=${nemo_tool_base_dir}/make_memo/trunk
    export PATH=${MAKEMEMO_ROOT}/scripts:${PATH}

    case "${SNAILWARE_SOFTWARE_VERSION}" in
        pro)
            source ${cadfael_setup_file} >> ${tmp_file_name} 2>&1 && do_cadfael_all_setup >> ${tmp_file_name} 2>&1
            source ${bayeux_setup_file}  >> ${tmp_file_name} 2>&1 && do_bayeux_all_setup  >> ${tmp_file_name} 2>&1
            source ${channel_setup_file} >> ${tmp_file_name} 2>&1 && do_channel_all_setup >> ${tmp_file_name} 2>&1
            source ${falaise_setup_file} >> ${tmp_file_name} 2>&1 && do_falaise_all_setup >> ${tmp_file_name} 2>&1

            export BAYEUX_BASE_DIR="${SNAILWARE_PRO_DIR}/bayeux"
            export BAYEUX_SRC_DIR="${BAYEUX_BASE_DIR}/build/${bayeux_version}/Source"
            export BAYEUX_BLD_DIR="${BAYEUX_BASE_DIR}/build/${bayeux_version}/Build"

            export FALAISE_BASE_DIR="${SNAILWARE_PRO_DIR}/falaise"
            export FALAISE_SRC_DIR="${FALAISE_BASE_DIR}/build/${falaise_version}/Source"
            export FALAISE_BLD_DIR="${FALAISE_BASE_DIR}/build/${falaise_version}/Build"

            export CHANNEL_BASE_DIR="${SNAILWARE_PRO_DIR}/channel"
            export CHANNEL_SRC_DIR="${CHANNEL_BASE_DIR}/build/${channel_version}/Source"
            export CHANNEL_BLD_DIR="${CHANNEL_BASE_DIR}/build/${channel_version}/Build"
            ;;
        branches/*|trunk|git)
            source ${cadfael_setup_file} >> ${tmp_file_name} 2>&1 && do_cadfael_all_setup >> ${tmp_file_name} 2>&1
            if [ $? -eq 0 ]; then
            # echo "NOTICE: do_cadfael_setup: Sourcing Cadfael/Python  ${PYTHON_VERSION}  is setup." >> ${tmp_file_name}
                echo "NOTICE: do_cadfael_setup: Sourcing Cadfael/GSL     ${GSL_VERSION}     is setup." >> ${tmp_file_name}
                echo "NOTICE: do_cadfael_setup: Sourcing Cadfael/CLHEP   ${CLHEP_VERSION}   is setup." >> ${tmp_file_name}
                echo "NOTICE: do_cadfael_setup: Sourcing Cadfael/XercesC ${XERCESC_VERSION} is setup." >> ${tmp_file_name}
                echo "NOTICE: do_cadfael_setup: Sourcing Cadfael/Boost   ${BOOST_VERSION}   is setup." >> ${tmp_file_name}
                echo "NOTICE: do_cadfael_setup: Sourcing Cadfael/ROOT    ${ROOT_VERSION}    is setup." >> ${tmp_file_name}
                echo "NOTICE: do_cadfael_setup: Sourcing Cadfael/Geant4  ${GEANT4_VERSION}  is setup." >> ${tmp_file_name}
            fi
            ;;
        *)
            echo "ERROR: do_nemo_bash_setup: NEMO software version '${SNAILWARE_SOFTWARE_VERSION}' is unkown !"
            export SNAILWARE_SETUP_DONE=0
            ;;
    esac

    # Grep errors
    local loading_error=$(cat ${tmp_file_name} | grep ERROR:)

    if [ "x${loading_error}" != "x" ]; then
        echo "${loading_error}"
        return 1
    fi

    # Add additionnal env variable
    export CADFAEL_BASE_DIR="${SNAILWARE_PRO_DIR}/cadfael"
    export CADFAEL_SRC_DIR="${CADFAEL_BASE_DIR}/build/${cadfael_version}/Source"
    export CADFAEL_BLD_DIR="${CADFAEL_BASE_DIR}/build/${cadfael_version}/Build"

    # Create NEMO_DEV_DIR just for backward compatibility
    export NEMO_DEV_DIR=$SNAILWARE_DEV_DIR

    if [ -f ${tmp_file_name} ]; then
        # Use gnome notification system
        if [ ${set_notification} = 0 ]; then
            cat ${tmp_file_name} | grep "Sourcing" | awk '{print "➜",$4,$5,$6,$7}'
        else
            notify-send -t 2000 -i bash "SuperNEMO '${SNAILWARE_SOFTWARE_VERSION}' settings:" \
                "`cat ${tmp_file_name} | grep "Sourcing" | awk '{print $3,$4,$5,$6,$7}'`"
        fi
    fi

    return 0
}

#echo "NOTICE: nemo@work: SNAILWARE_SOFTWARE_VERSION=${SNAILWARE_SOFTWARE_VERSION}"

# load nemo setup
if [ ! -n ${SNAILWARE_SOFTWARE_VERSION} ]; then
    echo "ERROR: nemo@work: 'SNAILWARE_SOFTWARE_VERSION' is not defined!"
    echo "ERROR: nemo@work: No NEMO setup will be loaded !"
    export SNAILWARE_SETUP_DONE=0
else
    do_nemo_bash_setup
    if [ $? -ne 0 ]; then
        echo "ERROR: nemo@work: Something bad occurs when loading NEMO settings !"
        export SNAILWARE_SETUP_DONE=0
    else
        export SNAILWARE_SETUP_DONE=1
    fi
fi

# go back to zshell
zsh

# end of .bashrc
