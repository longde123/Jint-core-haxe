using System;
using System.Collections.Generic;
namespace Jint.Runtime.Interop
{
    public interface ITypeConverter
    {
        
        object Convert(object value, Type type, IFormatProvider formatProvider);
        KeyValuePair<bool,object> TryConvert(object value, Type type, IFormatProvider formatProvider);
    }
}
