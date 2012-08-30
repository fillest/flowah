import os
from setuptools import setup, find_packages


requires = [
  'Chameleon==2.9.2',
  'Mako==0.7.2',
  'MarkupSafe==0.15',
  'PasteDeploy==1.5.0',
  'PyYAML==3.10',
  'Pygments==1.5',
  'SQLAlchemy==0.7.8',
  'WebHelpers==1.3',
  'WebOb==1.2.2',
  'argh==0.15.1',
  'argparse==1.2.1',
  'ordereddict==1.1',
  'pathtools==0.1.2',
  'psycopg2==2.4.5',
  'pyramid==1.3.3',
  'pyramid-debugtoolbar==1.0.2',
  'pyramid-tm==0.5',
  'repoze.lru==0.6',
  'transaction==1.3.0',
  'translationstring==1.1',
  'venusian==1.0a7',
  'waitress==0.8.1',
  'watchdog==0.6.0',
  'zope.deprecation==4.0.0',
  'zope.interface==4.0.1',
  'zope.sqlalchemy==0.7.1',
  'Fabric==1.4.3',
  'ssh==1.7.14',
  'pycrypto==2.6',
  # + sapyens
]

setup(name='flowah',
      version='0.2.0',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      test_suite='flowah',
      install_requires=requires,
      entry_points="""\
      [paste.app_factory]
        main = flowah:main
      [console_scripts]
        migrate = flowah.scripts.migrate:main
      """,
      )
