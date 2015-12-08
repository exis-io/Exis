from setuptools import setup, Extension

setup(
    name="pyRiffle",
    version="0.1.1",
    author="Damouse",
    description="Riffle client libraries for interacting over a fabric",
    packages=['riffle'],
    package_data={'riffle': ['libriffmantle.so']}, 
    runtime_library_dirs=['riffle'],
    library_dirs=['riffle'],
    include_package_data=True,
    install_requires=[
        'greenlet'
    ],
    entry_points={
        'console_scripts': [
            'reef=riffle.river:main',
        ],
    }
)