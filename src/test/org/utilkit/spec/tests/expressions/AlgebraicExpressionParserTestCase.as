package org.utilkit.spec.tests.expressions
{
	import flexunit.framework.Assert;
	
	import org.utilkit.expressions.parsers.AlgebraicExpressionParser;

	public class AlgebraicExpressionParserTestCase
	{
		protected var _parser:AlgebraicExpressionParser;
		
		[Before]
		public function setUp():void
		{
			this._parser = new AlgebraicExpressionParser();
			
			this._parser.configuration.variables.setItem("playedCount", 10);
			this._parser.configuration.variables.setItem("worldCount", 1);
		}
		
		[After]
		public function tearDown():void
		{
			this._parser = null;
		}
		
		[Test(description="Tests a basic sum using one variable")]
		public function calculatesBasicSumWithVariable():void
		{
			var expression:String = "playedCount + 5";
			var results:Number = this._parser.begin(expression);
			
			Assert.assertEquals(15, results);
			
			expression = "playedCount - 5";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(5, results);
		}
		
		[Test(description="Tests a complex sum using multiple variables")]
		public function calculatesComplexSumWithVariables():void
		{
			var expression:String = "(playedCount + 5) - (worldCount * 10)";
			var results:Number = this._parser.begin(expression);
			
			Assert.assertEquals(5, results);
			
			expression = "(playedCount * 5) + (worldCount + 100)";
			results = this._parser.begin(expression);
			
			Assert.assertEquals(151, results);
		}
	}
}