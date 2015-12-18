from setuptools import setup, Extension

setup(
    name="pyRiffle",
    version="0.2.0",
    author="Damouse",
    description="Riffle client libraries for interacting over a fabric",
    packages=['riffle'],
    package_data={'pymantle': ['pymantle.so']}, 
    runtime_library_dirs=['pymantle'],
    library_dirs=['pymantle'],
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