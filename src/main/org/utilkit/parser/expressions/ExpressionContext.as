package org.utilkit.parser.expressions
{
	import org.utilkit.util.StringUtil;

	public class ExpressionContext
	{
		// parentContext -> link to the parent context
		// tokenString -> the token string that starts this context rolling
		// 
		
		/**
		 * Parent context or null if this is the base context
		 */
		protected var _parentContext:ExpressionContext;
		
		/**
		 * The position of the context on the parent's `tokenString`.
		 */
		protected var _parentStartPosition:int = 0;
		protected var _parentEndPosition:int = int.MAX_VALUE;
		
		/** 
		 * Array of parsed expression tokens
		 */
		protected var _tokens:Vector.<Object>;
		
		protected var _tokenString:String = null;
		
		public function ExpressionContext(parentContext:ExpressionContext, parentStartPosition:int)
		{
			this._parentContext = parentContext;
			this._parentStartPosition = parentStartPosition;
			
			this._tokens = new Vector.<Object>();
		}
		
		public function get parentContext():ExpressionContext
		{
			return this._parentContext;
		}
		
		public function get parentStartPosition():int
		{
			return this._parentStartPosition;
		}
		
		public function get parentEndPosition():int
		{
			return this._parentEndPosition;
		}
		
		public function get tokens():Vector.<Object>
		{
			return this._tokens;
		}
		
		public function get tokenString():String
		{
			if (this.parentContext == null)
			{
				if (this._tokenString != null)
				{
					return this._tokenString;
				}
			}
			else
			{
				return this.parentContext.tokenString.substr(this.parentStartPosition, this.parentEndPosition);
			}
			
			return null;
		}
		
		public function get expressionParser():ExpressionParser
		{
			return this.parentContext.expressionParser;
		}
		
		public function parse():void
		{
			// set the source to parse and remove all the white space
			var tokenString:String = this.tokenString; //.replace(/\ /g, '');
			
			var token:String = "";
			
			for (var i:uint = 0; i < tokenString.length; i++)
			{
				var character:String = tokenString.charAt(i);
				var remainder:String = tokenString.substr(i);
				
				if (character == " ")
				{
					// skip white space
					continue;
				}
				
				// parse new contexts
				if (this.matches(remainder, this.expressionParser.contextOpen))
				{
					var context:ExpressionContext = new ExpressionContext(this, (i + (this.expressionParser.contextOpen.length)));
					context.parse();
					
					this._tokens.push(context.tokens);
					
					// skip to the end of the context, the parentEndPosition,
					// indicates the closing context operator, so we skip over that too
					i = (context.parentEndPosition);
					
					continue;
				}
				
				// found the end of ourself
				if (this.matches(remainder, this.expressionParser.contextClosed))
				{
					if (token != null && token != "")
					{
						this.tokens.push(token);
					}
						
					token = "";
					
					// move our ending to the last character
					this._parentEndPosition = this._parentStartPosition + i;
					
					break;
				}
				
				var operatorFound:Boolean = false;
				
				// find an operator
				for (var k:int = 0; k < this.expressionParser.operators.length; k++)
				{
					var operator:String = this.expressionParser.operators[k];
					
					// do we match?
					if (this.matches(remainder, operator))
					{
						if (token != null && token != "")
						{
							// drop our current token onto the stack
							this.tokens.push(token);
						}
						
						// clear the token
						token = "";
						
						// push the operator onto the stack
						this.tokens.push(operator);
						
						// skip over the operator in the string
						i = i + (operator.length - 1);
						
						// no need to build the operator character by character
						operatorFound = true;
						
						break;
					}
				}
				
				if (operatorFound)
				{
					operatorFound = false;
					
					continue;
				}
				
				// build the token character by character
				token += character;
			}
			
			if (token != null && token != "")
			{
				// push the last token onto the stack
				this.tokens.push(token);
			}
			
			if (this.parentEndPosition == int.MAX_VALUE && !(this.parentContext is ExpressionParser))
			{
				// missing a context ending, and were in a child so we need to end
				throw new InvalidExpressionException(InvalidExpressionException.TYPE_MISSING_CONTEXT_CLOSE);
			}
		}
		
		protected function matches(remainder:String, characters:String):Boolean
		{
			var stash:String = remainder.substr(0, characters.length);
			
			return (stash == characters);
		}
	}
}