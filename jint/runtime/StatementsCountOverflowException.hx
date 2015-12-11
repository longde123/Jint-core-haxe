package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class StatementsCountOverflowException extends system.Exception
{
    public function new()
    {
        super("The maximum number of statements executed have been reached.");
    }
}
