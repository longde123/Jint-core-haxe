using System.Collections.Generic;
using Jint.Parser.Ast;

namespace Jint.Parser
{
    public interface IFunctionDeclaration : IFunctionScope
    {
        Identifier Id { get; set; }
        IEnumerable<Identifier> Parameters { get; set; }
        Statement Body { get; set; }
        bool Strict { get; set; }
    }
}