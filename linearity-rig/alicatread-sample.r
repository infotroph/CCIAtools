
require(lubridate)

logfile = "ramplog.txt"


log = read.table(logfile)
names(log) = c(
	"timestring", 
	"id", 
	"psia", 
	"tempC", 
	"flow.vol", 
	"flow.mass", 
	"setflow", 
	"gas")

# Timestamps generated by python's datetime:isoformat, 
# which gives timezone offset as "-06:00". R's base::strptime() only 
# recognizes timezone offsets in the form "-0600", so we use the more 
# flexible datetime parser from the lubridate package.
log$time = parse_date_time(log$timestring, "ymdHMOSz",tz="Etc/GMT+6")