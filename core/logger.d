module logger;

import std.file;
import std.stream;
public import std.string;

class Logger
{
    public const char[] LOGFILE = "null07.log";

    private static Logger _instance = null;
    private File _fp = null;

    static Logger instance()
    {
        if (_instance is null)
          _instance = new Logger(LOGFILE);

        return _instance;  
    }

    this(char[] filename)
    {
        _fp = new File();
        _fp.create(filename, FileMode.Out);
    }

    ~this()
    {
        _fp.close();
    }

    void message(char[] m)
    {
        _fp.writeLine("MSG: " ~ m);
    }
}

