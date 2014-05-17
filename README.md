Crutch
======

A quick hack allowing you to monitor several miners on the same machine using a web browser as well as take corrective action if a miner gets stunned or crashes.

FEATURES
========

* Monitor miners regularly (check for process existence and monitor miner log patterns for signs of stunned hardware)
* Applies corrective action when anomaly is detected
* SBC (e.g. Raspberry Pi or BeagleBoard) friendly - configurable to write all non-essential data to ramdisk (/dev/shm) or tmpfs to reduce wear on SSD storage

TODO
====

* Write a proper readme and instructions on how to install & configure this
* Clean up PHP
