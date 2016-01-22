from setuptools import setup, Extension

setup(
    name="pyRiffle",
    version="0.2.0",
    description="Riffle client libraries for interacting over a fabric",
    author="Exis",
    url="http://www.exis.io",
    license="MIT",

    packages=["riffle"],
    include_package_data=True,

    install_requires=[
        'greenlet'
    ],

    classifiers=[
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.7",
        "Topic :: Software Development :: Libraries :: Python Modules"
    ]
)
