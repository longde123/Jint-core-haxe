package test.parser;
import haxe.unit.TestCase;
import jint.parser.JavaScriptParser;
import jint.parser.ast.Program;
import jint.parser.ast.*;
import jint.parser.ast.BinaryExpression;
/**
 * ...
 * @author paling
 */
class JavascriptParserTests extends TestCase
{
	private   var  _parser:JavaScriptParser = new JavaScriptParser();
	 
	 
	public  function  testShouldParseThis()
	{
		var program:Program = _parser.Parse("this");
		var body:Array<jint.parser.ast.Statement> = program.Body;
		
		assertTrue(body!=null);
		assertEquals(1, body.length);
		
		assertEquals(SyntaxNodes.ThisExpression, body[0].As(ExpressionStatement).Expression.Type);
	}
	public function  testShouldParseNull()
	{
		var program = _parser.Parse("null");
		var body = program.Body;

	   assertTrue(body!=null);
		assertEquals(1, body.length);
		assertEquals(SyntaxNodes.Literal,  body[0].As(ExpressionStatement).Expression.Type);
		assertEquals(null,  body[0].As(ExpressionStatement).Expression.As(Literal).Value);
		assertEquals("null",  body[0].As(ExpressionStatement).Expression.As(Literal).Raw);
	}
 
        public function  testShouldParseNumeric()
        {
            var program = _parser.Parse(
                "
                42
            ");
            var body = program.Body;

          assertTrue(body!=null);
            assertEquals(1, body.length);
            assertEquals(SyntaxNodes.Literal,  body[0].As(ExpressionStatement).Expression.Type);
            assertEquals(42.0,  body[0].As(ExpressionStatement).Expression.As(Literal).Value);
            assertEquals("42",  body[0].As(ExpressionStatement).Expression.As(Literal).Raw);
        }

 
        public function  testShouldParseBinaryExpression()
        {
            var  binary:BinaryExpression ;

            var program = _parser.Parse("(1 + 2 ) * 3");
            var body = program.Body;

			assertTrue(body!=null);
            assertEquals(1, body.length);
			binary =  body[0].As(ExpressionStatement).Expression.As(BinaryExpression);
			assertTrue(binary!=null);
            assertEquals(3.0, binary.Right.As(Literal).Value);
            assertEquals(BinaryOperator.Times, binary.Operator);
            assertEquals(1.0, binary.Left.As(BinaryExpression).Left.As(Literal).Value);
            assertEquals(2.0, binary.Left.As(BinaryExpression).Right.As(Literal).Value);
            assertEquals(BinaryOperator.Plus, binary.Left.As(BinaryExpression).Operator);
        }

	
	
}