package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import jint.parser.ast.ArrayExpression;
import jint.parser.ast.AssignmentExpression;
import jint.parser.ast.AssignmentOperator;
import jint.parser.ast.BinaryExpression;
import jint.parser.ast.BinaryOperator;
import jint.parser.ast.BlockStatement;
import jint.parser.ast.BreakStatement;
import jint.parser.ast.CallExpression;
import jint.parser.ast.CatchClause;
import jint.parser.ast.ConditionalExpression;
import jint.parser.ast.ContinueStatement;
import jint.parser.ast.DebuggerStatement;
import jint.parser.ast.DoWhileStatement;
import jint.parser.ast.EmptyStatement;
import jint.parser.ast.Expression;
import jint.parser.ast.ExpressionStatement;
import jint.parser.ast.ForInStatement;
import jint.parser.ast.ForStatement;
import jint.parser.ast.FunctionDeclaration;
import jint.parser.ast.FunctionExpression;
import jint.parser.ast.Identifier;
import jint.parser.ast.IfStatement;
import jint.parser.ast.IPropertyKeyExpression;
import jint.parser.ast.LabelledStatement;
import jint.parser.ast.Literal;
import jint.parser.ast.LogicalExpression;
import jint.parser.ast.LogicalOperator;
import jint.parser.ast.MemberExpression;
import jint.parser.ast.NewExpression;
import jint.parser.ast.ObjectExpression;
import jint.parser.ast.Program;
import jint.parser.ast.Property;
import jint.parser.ast.PropertyKind;
import jint.parser.ast.RegExpLiteral;
import jint.parser.ast.ReturnStatement;
import jint.parser.ast.SequenceExpression;
import jint.parser.ast.Statement;
import jint.parser.ast.SwitchCase;
import jint.parser.ast.SwitchStatement;
import jint.parser.ast.SyntaxNode;
import jint.parser.ast.SyntaxNodes;
import jint.parser.ast.ThisExpression;
import jint.parser.ast.ThrowStatement;
import jint.parser.ast.TryStatement;
import jint.parser.ast.UnaryExpression;
import jint.parser.ast.UnaryOperator;
import jint.parser.ast.UpdateExpression;
import jint.parser.ast.VariableDeclaration;
import jint.parser.ast.VariableDeclarator;
import jint.parser.ast.WhileStatement;
import jint.parser.ast.WithStatement;
import jint.parser.Comment;
import jint.parser.FunctionScope;
import jint.parser.IFunctionDeclaration;
import jint.parser.IFunctionScope;
import jint.parser.IVariableScope;
import jint.parser.JavaScriptParser;
import jint.parser.JavaScriptParser_Extra;
import jint.parser.JavaScriptParser_LocationMarker;
import jint.parser.JavaScriptParser_ParsedParameters;
import jint.parser.JavaScriptParser_Regexes;
import jint.parser.Location;
import jint.parser.Messages;
import jint.parser.ParserException;
import jint.parser.ParserExtensions;
import jint.parser.ParserOptions;
import jint.parser.Position;
import jint.parser.State;
import jint.parser.Token;
import jint.parser.Tokens;
import jint.parser.VariableScope; 
/**
 * ...
 * @author paling
 */

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		// entry point
		
		trace(Char.MaxValue);
		trace(Char.MinValue);
		
		var node :SyntaxNode= new VariableDeclaration();
		var node2 = node.As(VariableDeclaration);
		node2.Declarations;
			 
	}
	
}