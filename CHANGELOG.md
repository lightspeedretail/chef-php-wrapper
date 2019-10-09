php\_wrapper
======

3.3.0
-----
* Use token authentication for artifactory

3.2.0
-----
* Use private repo for php7.1 packages as well

3.1.0
-----
* Bumping composer to latest available (1.8.5)
* Use different source for php packages

3.0.1
-----
* 3.0.0 had broken php7 support via one of the resources renamed. Fixed in this release

3.0.0
-----
* DO-3084 Move away from the deprecated php5.6
** This is a breaking change because it changes the namespace used for a lot of php attributes

2.4.0
-----
* DO-2897 Support php 7.1

2.3.1
-----
* Fixed the in-place upgrade of composer
* Bumped composer version to 1.4.0

2.3.0
-----
* Bumped composer version to 1.3.3

2.2.0
-----
* Remove dependency on common\_attrs
* Change a default value to lazy to ensure it's content is cloned
* Bugfix template error for max\_requests

2.1.3
-----
* Bugfix symlinks

2.1.2
-----
* Bugfix php sapi detection

2.1.1
-----
* Bugfix php\_config actions

2.0.1
-----
* Add whyrun support to php\_composer\_binary and php\_composer\_command
* Add whyrun support to php\_config and php\_pool
* PHP FPM bugfixes

2.0.0
-----
* Initial rewrite
