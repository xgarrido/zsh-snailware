#!/bin/bash
# -*- mode: shell-script; -*-
#
# build_snailware
#
# A bash script to install all nemo software chain through cmake
#
#      Author: X. Garrido <xavier.garrido@lal.in2p3.fr.fr>
#        Date: 2013-01-20
#
# History:
#

appname="build_snailware"

declare -g path_set=0

declare -g aggregator_name
declare -g aggregator_svn_path
declare -g aggregator_branch_name
declare -g aggregator_base_dir
declare -g aggregator_logfile
declare -g aggregator_options
declare -g aggregator_config_version

function snailware::set_path ()
{
    __pkgtools__at_function_enter snailware::set_path

    if [ ${path_set} != 0 ];then
        __pkgtools__at_function_exit
        return 0
    fi

    # Take car of running machine
    case "${HOSTNAME}" in
        garrido-laptop)
            nemo_base_dir_tmp="/home/garrido/Workdir/NEMO"
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

    export SNAILWARE_BASE_DIR="${nemo_base_dir_tmp}"
    export SNAILWARE_PRO_DIR="${nemo_pro_dir_tmp}"
    export SNAILWARE_DEV_DIR="${nemo_dev_dir_tmp}"
    export SNSW_SIMULATION_DIR="${nemo_simulation_dir_tmp}"

    # Export main env. variables
    which ccache > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        export CXX="ccache g++"
        export CC="ccache gcc"
    fi

    test -n "${PATH}"              && export PATH
    test -n "${LD_LIBRARY_PATH}"   && export LD_LIBRARY_PATH
    test -n "${CMAKE_MODULE_PATH}" && export CMAKE_MODULE_PATH

    path_set=1
    __pkgtools__at_function_exit
    return 0
}

function snailware::source_aggregator ()
{
    __pkgtools__at_function_enter snailware::source_aggregator

    pkgtools__msg_notice "Source '${aggregator_name}' aggregator"

    local upname=${aggregator_name:u}
    local install_dir=${aggregator_base_dir}/install/${aggregator_branch_name}
    export ${upname}_PREFIX=${install_dir}
    export ${upname}_INCLUDE_DIR=${install_dir}/include
    export ${upname}_LIB_DIR=${install_dir}/lib
    export ${upname}_BIN_DIR=${install_dir}/bin
    export ${upname}_SHARE_DIR=${install_dir}/share
    export ${upname}_ETC_DIR=${install_dir}/etc
    export ${upname}_DIR=${install_dir}/share/cmake/Modules

    export PATH="${install_dir}/bin:${PATH}"
    export LD_LIBRARY_PATH="${install_dir}/lib:${LD_LIBRARY_PATH}"
    export CMAKE_MODULE_PATH="${install_dir}/share/cmake/Modules:${CMAKE_MODULE_PATH}"

    # if [ -n "${PKG_CONFIG_PATH}" ]; then
    #     export PKG_CONFIG_PATH="${CADFAEL_LIB_DIR}/pkgconfig:${PKG_CONFIG_PATH}"
    # else
    #     export PKG_CONFIG_PATH="${CADFAEL_LIB_DIR}/pkgconfig"
    # fi

    if [ ${aggregator_name} = cadfael ]; then
        export BOOST_ROOT=${CADFAEL_PREFIX}
        export LD_LIBRARY_PATH="${CADFAEL_LIB_DIR}/root:${LD_LIBRARY_PATH}"
    elif [ ${aggregator_name} = bayeux ]; then
        for i in ${install_dir}/share/*
        do
            local base=$(basename $i)
            local upbase=${base:u}
            export ${upbase}_DATA_DIR=${install_dir}/share/${base}
        done
    fi

    __pkgtools__at_function_exit
    return 0
}

function snailware::set_aggregator ()
{
    __pkgtools__at_function_enter snailware::set_aggregator

    aggregator_logfile=/tmp/${aggregator_name}_${aggregator_branch_name}.log
    aggregator_base_dir=${SNAILWARE_PRO_DIR}/${aggregator_name}

    if [ ! -d  ${aggregator_base_dir}/repo ]; then
        pkgtools__msg_warning "${aggregator_base_dir}/repo directory not created"
        mkdir -p ${aggregator_base_dir}/repo
    fi
    cd ${aggregator_base_dir}/repo

    __pkgtools__at_function_exit
    return 0
}

function snailware::get_aggregator ()
{
    __pkgtools__at_function_enter snailware::get_aggregator

    pkgtools__msg_notice "Getting/updating ${aggregator_name}"
    go-svn2git -username garrido -verbose ${aggregator_svn_path}
    git checkout ${aggregator_branch_name}

    __pkgtools__at_function_exit
    return 0
}

function snailware::build_aggregator ()
{
    __pkgtools__at_function_enter snailware::build_aggregator

    pkgtools__msg_err $CMAKE_MODULE_PATH
    pkgtools__msg_err $CADFAEL_DIR

    pkgtools__msg_notice "Configure ${aggregator_name}"
    ./pkgtools.d/pkgtool configure                                                    \
        --install-prefix     ${aggregator_base_dir}/install/${aggregator_branch_name} \
        --ep-build-directory ${aggregator_base_dir}/build/${aggregator_branch_name}   \
        --download-directory ${aggregator_base_dir}/download                          \
        --config             ${aggregator_config_version}                             \
        ${aggregator_options} | tee -a ${aggregator_logfile} 2>&1

    pkgtools__msg_err $CADFAEL_DIR

    pkgtools__msg_notice "Build/install ${aggregator_name}"
    ./pkgtools.d/pkgtool install | tee -a ${aggregator_logfile} 2>&1

    __pkgtools__at_function_exit
    return 0
}

function snailware::set_cadfael
{
    __pkgtools__at_function_enter snailware::set_cadfael

    # Setting paths
    snailware::set_path

    aggregator_name="cadfael"
    aggregator_branch_name="master"
    aggregator_svn_path="https://svn.lal.in2p3.fr/users/garrido/Workdir/NEMO/SuperNEMO/Cadfael"
    aggregator_options="--with-all             \
                        --without-mysql	       \
			--without-hdf5	       \
			--without-systemc      \
			--without-python       \
			--root-version 5.34.03 \
			--boost-version 1.51.0 \
			--with-test"
    snailware::set_aggregator

    __pkgtools__at_function_exit
    return 0
}

function snailware::build_cadfael ()
{
    __pkgtools__at_function_enter snailware::build_cadfael

     (
        snailware::set_cadfael
        snailware::get_aggregator
        snailware::build_aggregator
    )

    __pkgtools__at_function_exit
    return 0
}

function snailware::set_bayeux ()
{
    __pkgtools__at_function_enter snailware::set_bayeux

    # Setting paths
    snailware::set_path

    # Setting Cadfael
    snailware::set_cadfael
    snailware::source_aggregator

    # Building Bayeux
    aggregator_name="bayeux"
    aggregator_branch_name="master"
    aggregator_svn_path="https://nemo.lpc-caen.in2p3.fr/svn/Bayeux"
    aggregator_config_version="legacy"
    aggregator_options="--with-all \
                        --with-test"
    snailware::set_aggregator

    __pkgtools__at_function_exit
    return 0
}

function snailware::build_bayeux ()
{
    __pkgtools__at_function_enter snailware::build_bayeux

    (
        snailware::set_bayeux
        snailware::get_aggregator
        snailware::build_aggregator
        pkgtools__msg_err $CADFAEL_DIR
    )

    __pkgtools__at_function_exit
    return 0
}

function snailware::set_channel ()
{
    __pkgtools__at_function_enter snailware::set_channel

    # Setting paths
    snailware::set_path

    # Setting Cadfael
    snailware::set_cadfael
    snailware::source_aggregator

    aggregator_name="channel"
    aggregator_branch_name="master"
    aggregator_svn_path="https://nemo.lpc-caen.in2p3.fr/svn/snsw/devel/Channel"
    aggregator_config_version="trunk"
    aggregator_options="--with-all \
                        --with-test"
    snailware::set_aggregator

    __pkgtools__at_function_exit
    return 0
}

function snailware::build_channel ()
{
    __pkgtools__at_function_enter snailware::build_channel

    (
        snailware::set_channel
        snailware::get_aggregator
        snailware::build_aggregator
    )

    __pkgtools__at_function_exit
    return 0
}

function snailware::set_falaise ()
{
    __pkgtools__at_function_enter snailware::set_falaise

    # Setting paths
    snailware::set_path

    # Setting Cadfael
    snailware::set_cadfael
    snailware::source_aggregator

    # Setting Bayeux
    snailware::set_bayeux
    snailware::source_aggregator

    # Setting Channel
    snailware::set_channel
    snailware::source_aggregator

    aggregator_name="falaise"
    aggregator_branch_name="master"
    aggregator_svn_path="https://nemo.lpc-caen.in2p3.fr/svn/snsw/devel/Falaise"
    aggregator_config_version="trunk"
    aggregator_options="--with-all        \
                        --with-snanalysis \
                        --with-test"
    snailware::set_aggregator

    __pkgtools__at_function_exit
    return 0
}

function snailware::build_falaise ()
{
    __pkgtools__at_function_enter snailware::build_falaise

    (
        snailware::set_falaise
        snailware::get_aggregator
        snailware::build_aggregator
    )

    __pkgtools__at_function_exit
    return 0
}

function snailware::set_chevreuse ()
{
    __pkgtools__at_function_enter snailware::set_chevreuse

    # Setting paths
    snailware::set_path

    # Setting Cadfael
    snailware::set_cadfael
    snailware::source_aggregator

    # Setting Bayeux
    snailware::set_bayeux
    snailware::source_aggregator

    # Setting Falaise
    snailware::set_falaise
    snailware::source_aggregator

    aggregator_name="chevreuse"
    aggregator_branch_name="master"
    aggregator_svn_path="https://nemo.lpc-caen.in2p3.fr/svn/snsw/devel/Chevreuse"
    aggregator_options="--with-all  \
                        --with-test"
    snailware::set_aggregator

    __pkgtools__at_function_exit
    return 0
}

function snailware::remove_chevreuse ()
{
    __pkgtools__at_function_enter snailware::remove_chevreuse
      # Setting paths
    snailware::set_path

    (
    )

    __pkgtools__at_function_exit
    return 0
}

function snailware::build_chevreuse ()
{
    __pkgtools__at_function_enter snailware::build_chevreuse

    (
        snailware::set_chevreuse
        snailware::get_aggregator
        snailware::install_aggregator
    )

    __pkgtools__at_function_exit
    return 0
}

function snailware::build_all ()
{
    __pkgtools__at_function_enter snailware::build_all

    (
        snailware::build_cadfael && \
        snailware::build_bayeux  && \
        snailware::build_channel && \
        snailware::build_falaise && \
        snailware::build_chevreuse
    )

    __pkgtools__at_function_exit
    return 0
}

function snailware::test ()
{
    __pkgtools__at_function_enter snailware::test

    # Setting paths
    snailware::set_path

    # Setting Cadfael
    aggregator_name="bayeux"
    aggregator_branch_name="legacy"
    snailware::set_aggregator
    snailware::source_aggregator

    __pkgtools__at_function_exit
    return 0
}

# end of build_snailware
