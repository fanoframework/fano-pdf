REM------------------------------------------------------------
REM [[APP_NAME]] ([[APP_URL]])
REM
REM @link      [[APP_REPOSITORY_URL]]
REM @copyright Copyright (c) [[COPYRIGHT_YEAR]] [[COPYRIGHT_HOLDER]]
REM @license   [[LICENSE_URL]] ([[LICENSE]])
REM-------------------------------------------------------------

REM------------------------------------------------------
REM Scripts to setup configuration files
REM------------------------------------------------------

IF EXIST config\config.json.sample (copy config\config.json.sample config\config.json)
IF EXIST config\config.ini.sample (copy config\config.ini.sample config\config.ini)
copy build.prod.cfg.sample build.prod.cfg
copy build.dev.cfg.sample build.dev.cfg
copy build.cfg.sample build.cfg