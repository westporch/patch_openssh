#!/bin/bash
# Hyun-gwan Seo(westporch@debianusers.or.kr)

SRC_DIR="/usr/local/src"
LATEST_OPENSSH_FNAME="openssh-9.2p1.tar.gz"  # 최신 OpenSSH 소스 파일(참고: https://ftp.jaist.ac.jp/pub/OpenBSD/OpenSSH/portable/)
LATEST_OPENSSH_DNAME="${LATEST_OPENSSH_FNAME:0:13}" # LATEST_OPENSSL_FNAME을 압축 해제한 후의 디렉터리 이름(예를 들어 openssh-9.2p1)
OPENSSH_DIR="/usr/local/ssh"
OPENSSL_SRC_DIR="/usr/local/src/openssl-1.1.1t"


function check_pkg_dependency()
{
    pkg_list=("gcc" "make" "perl")

    for ((idx=0; idx < ${#pkg_list[@]}; idx++))
    do
        if ! [ -x "$(command -v ${pkg_list[$idx]})" ]; then
            echo "${pkg_list[$idx]} is not installed."
            exit 1
        fi
    done

	
    pkg2_list=("zlib-devel" "openssl-devel")
	
	for ((idx=0; idx < ${#pkg2_list[@]}; idx++))
	do
		if [ "$(rpm -qa | grep ${pkg2_list[$idx]} | wc -l)" -eq 0 ]; then
			echo "${pkg2_list[$idx]} is not installed."
			exit 1
		fi
	done
}


function prepare_compilation()
{
	# SRC_DIR이 존재하지 않으면, SRC_DIR 디렉터리 생성
	if ! [ -d $SRC_DIR ]; then
		mkdir -p $SRC_DIR
	fi

	# LATEST_OPENSSH_FNAME이 존재하지 않으면, 프로그램(path_openssh.sh) 종료
	if ! [ -f $SRC_DIR/$LATEST_OPENSSH_FNAME ]; then
		echo "$LATEST_OPENSSH_FNAME does not exists in $SRC_DIR."
		exit 1
	fi
}


# OpenSSH 소스 컴파일
function compile_openssl()
{
	tar xvf $SRC_DIR/$LATEST_OPENSSH_FNAME -C $SRC_DIR
	
	cd $SRC_DIR/$LATEST_OPENSSH_DNAME
	./configure --prefix=$OPENSSH_DIR --with-ssl-dir=$OPENSSL_SRC_DIR
	make && make install
}


function create_symlink()
{
	sym_list=("ssh" "ssh-add" "ssh-agent" "scp" "sftp" "ssh-keygegn" "ssh-keyscan")
	
	for ((idx=0; idx < ${#sym_list[@]}; idx++))
	do
		ln -sf $OPENSSH_DIR/bin/${sym_list[$idx]} /usr/bin/${sym_list[$idx]}
	done
	
	
	# 심볼릭 링크(sshd)
	ln -sf $OPENSSH_DIR/sbin/sshd /usr/bin/sshd
}

function get_status_sshd()
{
	systemctl restart sshd
	systemctl status sshd
}


function get_openssh_version()
{
	ssh -V
}


check_pkg_dependency
prepare_compilation	
compile_openssl
create_symlink
get_status_sshd
get_openssh_version
