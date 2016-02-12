from setuptools import setup, Extension

setup(
    name="pyRiffle",
    version="0.2.5",
    description="Riffle client libraries for interacting over a fabric",
    author="Exis",
    url="http://www.exis.io",
    license="MIT",

    packages=["riffle"],
    include_package_data=True,

    install_requires=[
        'docopt>=0.6.2',
        'greenlet>=0.4.9',
        'PyYAML>=3.11'
    ],

    entry_points={
        'console_scripts': [
            'exis = riffle.exis:main'
        ]
    },

    classifiers=[
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.7",
        "Topic :: Software Development :: Libraries :: Python Modules"
    ]
)
