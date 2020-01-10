import os, parsecfg, terminal, logging
# include connection
from connection import getDriver

# file logging setting
let logConfigFile = getCurrentDir() & "/config/logging.ini"
# try:
#   {.gcsafe.}:
#     let conf = loadConfig(logConfigFile)
#   let isFileOutString = conf.getSectionValue("Log", "file")
#   if isFileOutString == "true":
#     let logPath = conf.getSectionValue("Log", "logDir") & "/log.log"
#     createDir(parentDir(logPath))
#     newRollingFileLogger(logPath, mode=fmAppend, fmtStr=verboseFmtStr).addHandler()
# except:
#   discard


proc driverTypeError*() =
  let driver = getDriver()
  if driver != "sqlite" and driver != "mysql" and driver != "postgres":
    raise newException(OSError, "invalid DB driver type")


proc logger*(output: any, args:varargs[string]) =
  # get Config file
  {.gcsafe.}:
    let conf = loadConfig(logConfigFile)
  # console log
  let isDisplayString = conf.getSectionValue("Log", "display")
  if isDisplayString == "true":
    let logger = newConsoleLogger()
    logger.log(lvlInfo, $output & $args)
  # file log
  let isFileOutString = conf.getSectionValue("Log", "file")
  if isFileOutString == "true":
    # info $output & $args
    let logPath = conf.getSectionValue("Log", "logDir") & "/log.log"
    createDir(parentDir(logPath))
    let logger = newRollingFileLogger(logPath, mode=fmAppend, fmtStr=verboseFmtStr)
    logger.log(lvlInfo, $output & $args)
    flushFile(logger.file)


proc echoErrorMsg*(msg:string) =
  # console log
  styledWriteLine(stdout, fgRed, bgDefault, msg, resetStyle)
  # file log
  {.gcsafe.}:
    let conf = loadConfig(logConfigFile)
  let isFileOutString = conf.getSectionValue("Log", "file")
  if isFileOutString == "true":
    let path = conf.getSectionValue("Log", "logDir") & "/error.log"
    let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
    logger.log(lvlError, msg)
    flushFile(logger.file)
