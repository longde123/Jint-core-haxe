using System;
using Jint.Native;
using Jint.Native.Error;

namespace Jint.Runtime
{
    public class JavaScriptException : Exception
    {
        private JsValue _errorObject;
        public string _Message;

        public override string Message
        {
            get
            {
                return _Message;
            }
        }
        public JavaScriptException()
            : base("")
        {
        }
        public JavaScriptException Creator(ErrorConstructor errorConstructor)
        {
            _errorObject = errorConstructor.Construct(Arguments.Empty);
            return this;
        }

        public JavaScriptException Creator(ErrorConstructor errorConstructor, string message)
        {
            _Message = message;
            _errorObject = errorConstructor.Construct(new JsValue[] { message });
            return this;
        }

        public JavaScriptException Creator(JsValue error)
        {
            _Message = GetErrorMessage(error);
            _errorObject = error;
            return this;
        }

        private static string GetErrorMessage(JsValue error)
        {
            if (error.IsObject())
            {
                var oi = error.AsObject();
                var message = oi.Get("message").AsString();
                return message;
            }
            else
                return string.Empty;
        }

        public JsValue Error { get { return _errorObject; } }

        public override string ToString()
        {
            return _errorObject.ToString();
        }

        public Jint.Parser.Location Location { get; set; }

        public int LineNumber { get { return null == Location ? 0 : Location.Start.Line; } }

        public int Column { get { return null == Location ? 0 : Location.Start.Column; } }
    }
}
