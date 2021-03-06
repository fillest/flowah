from fabric.api import local, env, sudo, run, put
from fabric.utils import abort
from fabric.context_managers import lcd, prefix, settings, cd
from fabric.utils import warn, puts
from fabric.contrib.console import confirm
from glob import glob
from os.path import basename, exists


BUILD_DIR = '/tmp/flowah_build'


def build ():
    local('cp -r . ' + BUILD_DIR)
    local('rm -r {build_dir}/flowah.egg-info'.format(build_dir = BUILD_DIR))

    with lcd(BUILD_DIR):
        # local('tar czf /tmp/flowah_static.tar.gz -C flowah static')
        # local('rm -r flowah/static')

        local('python setup.py sdist')

def deploy ():
    try:
        build()
        sdist_remote_path = upload_dist()
        upload_configs()
        upload_migrations()
        stop()

        with prefix('source /opt/flowah/venv/bin/activate'):
            sudo('(pip freeze | grep flowah) && pip uninstall --yes flowah || :', user = 'flowah')
            sudo('pip install ' + sdist_remote_path, user = 'flowah')
            sudo('pip install --upgrade git+https://github.com/fillest/sapyens.git', user = 'flowah')

            with cd('/opt/flowah'):
                sudo('migrate production.ini', user = 'flowah')
        run('rm ' + sdist_remote_path)

        start()
    finally:
        clean()

def upload_dist ():
    sdist_path = glob(BUILD_DIR + '/dist/flowah*.tar.gz')[0]
    sdist_fname = basename(sdist_path)
    sdist_remote_path = '/tmp/' + sdist_fname
    put(sdist_path, sdist_remote_path)
    return sdist_remote_path

def upload_migrations ():
    with lcd(BUILD_DIR):
        local('tar czf /tmp/flowah_migrations.tar.gz -C flowah/data migrations')
    put('/tmp/flowah_migrations.tar.gz', '/tmp/')
    sudo('tar xzf /tmp/flowah_migrations.tar.gz -C /opt/flowah/', user = 'flowah')
    sudo('rm /tmp/flowah_migrations.tar.gz')

def clean ():
    local('rm -rf ' + BUILD_DIR)
    # local('rm -f /tmp/flowah_static.tar.gz')
    local('rm -f /tmp/flowah_migrations.tar.gz')

def upload_configs ():
    put('supervisord.conf', '/opt/flowah/', use_sudo = True)
    sudo('chown flowah:flowah /opt/flowah/supervisord.conf')

    if exists('production.ini'):
        put('production.ini', '/opt/flowah/', use_sudo = True, mode = 0400)
        sudo('chown flowah:flowah /opt/flowah/production.ini')
    else:
       warn('no production.ini found')

# def upload_static ():
#     put('/tmp/flowah_static.tar.gz', '/tmp/')
#     sudo('rm -rf /opt/flowah/static')
#     sudo('mkdir /opt/flowah/static', user = 'flowah')
#     sudo('tar xzf /tmp/flowah_static.tar.gz -C /opt/flowah', user = 'flowah')
#     sudo('rm /tmp/flowah_static.tar.gz')

def start ():
    sudo('supervisorctl start flowah')

def stop ():
    sudo('supervisorctl stop flowah')

def restart ():
    stop()
    start()
