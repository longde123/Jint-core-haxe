using System.Collections.Generic;
using System.Linq;
using Jint.Native;

namespace Jint.Runtime.Environments
{
    /// <summary>
    /// Represents a declarative environment record
    /// http://www.ecma-international.org/ecma-262/5.1/#sec-10.2.1.1
    /// </summary>
    public sealed class DeclarativeEnvironmentRecord : EnvironmentRecord
    {
        private readonly Engine _engine;
        private readonly IDictionary<string, Binding> _bindings = new Dictionary<string, Binding>();

        public DeclarativeEnvironmentRecord(Engine engine)
            : base(engine)
        {
            _engine = engine;
        }

        public override bool HasBinding(string name)
        {
            return _bindings.ContainsKey(name);
        }

        public override void CreateMutableBinding(string name, bool canBeDeleted = false)
        {
            var binding = new Binding();
            binding.Value = Undefined.Instance;
            binding.CanBeDeleted = canBeDeleted;
            binding.Mutable = true;
            _bindings.Add(name, binding);
        }

        public override void SetMutableBinding(string name, JsValue value, bool strict)
        {
            var binding = _bindings[name];
            if (binding.Mutable)
            {
                binding.Value = value;
            }
            else
            {
                if (strict)
                {
                    throw new JavaScriptException().Creator(_engine.TypeError, "Can't update the value of an immutable binding.");
                }
            }
        }

        public override JsValue GetBindingValue(string name, bool strict)
        {
            var binding = _bindings[name];

            if (!binding.Mutable && binding.Value.Equals(Undefined.Instance))
            {
                if (strict)
                {
                    throw new JavaScriptException().Creator(_engine.ReferenceError, "Can't access anm uninitiazed immutable binding.");
                }

                return Undefined.Instance;
            }

            return binding.Value;
        }

        public override bool DeleteBinding(string name)
        {
            Binding binding;
            if (!_bindings.TryGetValue(name, out binding))
            {
                return true;
            }

            if (!binding.CanBeDeleted)
            {
                return false;
            }

            _bindings.Remove(name);

            return true;
        }

        public override JsValue ImplicitThisValue()
        {
            return Undefined.Instance;
        }

        /// <summary>
        /// Creates a new but uninitialised immutable binding in an environment record.
        /// </summary>
        /// <param name="name">The identifier of the binding.</param>
        public void CreateImmutableBinding(string name)
        {

            var binding = new Binding();
            binding.Value = Undefined.Instance;
            binding.Mutable = false;
            binding.CanBeDeleted = false;

            _bindings.Add(name, binding);
        }

        /// <summary>
        /// Sets the value of an already existing but uninitialised immutable binding in an environment record.
        /// </summary>
        /// <param name="name">The identifier of the binding.</param>
        /// <param name="value">The value of the binding.</param>
        public void InitializeImmutableBinding(string name, JsValue value)
        {
            var binding = _bindings[name];
            binding.Value = value;
        }

        /// <summary>
        /// Returns an array of all the defined binding names
        /// </summary>
        /// <returns>The array of all defined bindings</returns>
        public override string[] GetAllBindingNames()
        {
            return _bindings.Keys.ToArray();
        }
    }
}
