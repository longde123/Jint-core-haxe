using System;
using System.Globalization;
using System.Linq;
using System.Reflection;
using Jint.Native;

namespace Jint.Runtime.Descriptors.Specialized
{
    public sealed class IndexDescriptor : PropertyDescriptor
    {
        private readonly Engine _engine;
        private readonly object _key;
        private readonly object _item;
        private readonly PropertyInfo _indexer;
        private readonly MethodInfo _containsKey;

        public IndexDescriptor(Engine engine, Type targetType, string key, object item)
        {
            _engine = engine;
            _item = item;

            // get all instance indexers with exactly 1 argument
            var indexers = targetType
                .GetProperties(BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);

            // try to find first indexer having either public getter or setter with matching argument type
            foreach (var indexer in indexers)
            {
                if (indexer.GetIndexParameters().Length != 1) continue;
                if (indexer.GetGetMethod() != null || indexer.GetSetMethod() != null)
                {
                    var paramType = indexer.GetIndexParameters()[0].ParameterType;

                    var converter= _engine.ClrTypeConverter.TryConvert(key, paramType, CultureInfo.InvariantCulture  );
                    if (converter.Key)
                    {

                        _key = converter.Value;
                        _indexer = indexer;
                        // get contains key method to avoid index exception being thrown in dictionaries
                        _containsKey = targetType.GetMethod("ContainsKey", new Type[] { paramType });
                        break;

                    }
                }
            }

            // throw if no indexer found
            if (_indexer == null)
            {
                throw new InvalidOperationException("No matching indexer found.");
            }

            Writable = true;
        }


        public override JsValue Value
        {
            get
            {
                var getter = _indexer.GetGetMethod();

                if (getter == null)
                {
                    throw new InvalidOperationException("Indexer has no public getter.");
                }

                object[] parameters = new object[] { _key };

                if (_containsKey != null)
                {
                    var invokeValue=(bool?)_containsKey.Invoke(_item, parameters);
                    if (invokeValue.Value != true)
                    {
                        return JsValue.Undefined;
                    }
                }
                
                try
                {
                    return JsValue.FromObject(_engine, getter.Invoke(_item, parameters));
                }
                catch
                {
                    return JsValue.Undefined;
                }
            }

            set
            {
                var setter = _indexer.GetSetMethod();
                if (setter == null)
                {
                    throw new InvalidOperationException("Indexer has no public setter.");
                }

                object[] parameters = new object[] { _key, value != null ? value.ToObject() : null };
                setter.Invoke(_item, parameters);
            }
        }
    }
}