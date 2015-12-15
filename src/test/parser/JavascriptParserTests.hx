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
 @:file("Scripts/jQuery.js")
 class JQuery extends flash.utils.ByteArray
{
    
}
 @:file("Scripts/underscore.js")
 class Underscore extends flash.utils.ByteArray
{
    
}
 @:file("Scripts/backbone.js")
 class Backbone extends flash.utils.ByteArray
{
    
}
 @:file("Scripts/mootools.js")
 class Mootools extends flash.utils.ByteArray
{
    
}
 @:file("Scripts/angular.js")
 class Angular extends flash.utils.ByteArray
{
    
}
 @:file("Scripts/JSXTransformer.js")
 class JSXTransformer extends flash.utils.ByteArray
{
    
}
 @:file("Scripts/handlebars.js") 
 class Handlebars extends flash.utils.ByteArray
{
    
}
class JavascriptParserTests extends TestCase
{
	private   var  _parser:JavaScriptParser = new JavaScriptParser();
	 
	public function testShouldParseScriptFile( )
	{
	  
		var stream = [
		new JQuery().toString(),
        new Underscore().toString(),
        new Backbone().toString(),
        new Mootools().toString(),
        new Angular().toString(),
        new JSXTransformer().toString(),
        new Handlebars().toString()];
		for (  source in stream)
		{
					var parser = new JavaScriptParser();
					var program = parser.Parse(source); 
					trace(program.Body.length);
					assertTrue(program!=null);
		}
	}
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
		public function  testShouldParseNumericLiterals()
        {
			var Theory:Array<Array<Dynamic>>=[
			[0, "0"],
			[42, "42"],
			[0.14, "0.14"],
			[3.14159, "3.14159"],
			[6.02214179e+23, "6.02214179e+23"],
			[1.492417830e-10, "1.492417830e-10"],
			[0, "0X0"],
			[0, "0X0;"],
			[0xabc, "0Xabc"],
			[0xdef, "0Xdef"],
			[0x1A, "0X1A"],
			[0x10, "0x10"],
			[0x100, "0x100"],
			[0x04, "0X04"],
			[2, "02"],
			[10, "012"],
			[10, "0012"]];
			for  (i in 0...Theory.length)
			{
				var data = Theory[i];
				ShouldParseNumericLiterals(data[0], data[1]);
			}
		}
        function   ShouldParseNumericLiterals( expected,  source)
        {
            var literal;

            var program = _parser.Parse(source);
            var body = program.Body;
			
			assertTrue(body!=null);
            assertEquals(1, body.length );
            literal = body[0].As(ExpressionStatement).Expression.As(Literal);
			
			assertTrue(literal != null); 
            assertEquals(expected,Std.parseFloat(literal.Value));
        }
	 	/*
		public function  testShouldParseStringLiterals()
        {
				var Theory:Array<Array<Dynamic>>=[
				["Hello", "'Hello'"], 
				["\u0061", "'\u0061'"],
				["\x61", "'\x61'"],
				["Hello\nworld", "'Hello\nworld'"],
				["Hello\\\nworld", "'Hello\\\nworld'"]];
				for  (i in 0...Theory.length)
				{
					var data = Theory[i];
					ShouldParseStringLiterals(data[0], data[1]);
				}
		}

        public function ShouldParseStringLiterals(  expected,   source)
        {
            var literal:Literal;

            var program = _parser.Parse(source);
            var body = program.Body;
			 
			assertTrue(body!=null);
            assertEquals(1, body.length );
			literal = body[0].As(ExpressionStatement).Expression.As(Literal);
			assertTrue(literal != null); 
            assertEquals(expected, literal.Value);
		 
        }
	
		public void ShouldInsertSemicolons(string source)
        {
            var program = _parser.Parse(source);
            var body = program.Body;

            Assert.NotNull(body);
        }
 
		*/
       public function testShouldProvideLocationForMultiLinesStringLiterals()
        {
           var source = "'\\\\'";
		   trace(source.length);
            var program = _parser.Parse(source);
            var expr = program.Body[0].As(ExpressionStatement).Expression;
            assertEquals(1, expr.Location.Start.Line);
            assertEquals(0, expr.Location.Start.Column);
        //    assertEquals(3, expr.Location.End.Line);
          //  assertEquals(1, expr.Location.End.Column);
        }
	
	

        

   
	 
}