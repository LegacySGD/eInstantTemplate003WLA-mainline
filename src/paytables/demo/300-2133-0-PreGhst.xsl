<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>
			
			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,getType,findWinAmount,close">
				<lxslt:script lang="javascript">
					<![CDATA[

					const crosswordWidth = 11;
					const crosswordHeight = 11;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, idxOfCrossword)
					{
						var scenario = getScenario(jsonContext);
						var crosswords = scenario.split("|");
						var crosswordBoards = [];
						var crosswordLetters = [];
						
						var result = [];						

						for(var numOfCrossword = 0; numOfCrossword < crosswords.length; ++numOfCrossword)
						{
							var crosswordContent = crosswords[numOfCrossword].split(",");
							crosswordBoards[numOfCrossword] = crosswordContent[0];
							crosswordLetters[numOfCrossword] = crosswordContent[1];
							}

						if(idxOfCrossword == 1)
						{	
							result.push(close());
							}

						result.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable"');

						var crosswordLetter = crosswordLetters[idxOfCrossword].split("");
						
						result.push('<tr><td class="tablehead" colspan="' + crosswordLetter.length + '">');
						result.push(getTranslationByName("crossword", translations) + ' ' + (idxOfCrossword+1));
						
						//Drawn Letters
						result.push('<tr><td class="tablehead" colspan="' + crosswordLetter.length + '">');
						result.push(getTranslationByName("drawnLetters", translations));
						result.push('</td></tr>');

						result.push('<tr>');
						for(var idxOfLetter = 0; idxOfLetter < crosswordLetter.length; ++idxOfLetter)
						{

							result.push('<td class="tablebody">');
							result.push(crosswordLetter[idxOfLetter]);
							result.push('</td>');
							if(idxOfLetter == (crosswordLetter.length / 2) - 1)
							{
								result.push('</tr>');
								result.push('<tr>');
							}								
						}
						result.push('</tr>');
								
						//Words to Match
						result.push('<tr><td class="tablehead" colspan="' + crosswordLetter.length + '">');
						result.push(getTranslationByName("wordToMatch", translations));
						result.push('</td></tr>');

						var crosswordWords = getCrosswordWords(crosswordBoards[idxOfCrossword]);
						var verticalHotWord = findVerticalHotWord(crosswordBoards[idxOfCrossword]);
						var matchCount = 0;

						for(var idxOfWord = 0; idxOfWord < crosswordWords.length; ++idxOfWord)
								{
							result.push('<tr><td class="tablebody" colspan="' + crosswordLetter.length + '">');
							var word = crosswordWords[idxOfWord];
							matchChecked = checkMatch(crosswordLetter, word);
							if(matchChecked)
									{
								++matchCount;
								result.push(getTranslationByName("matched", translations) + ': ');
							}

							result.push(word);
							if((idxOfCrossword == 0 && idxOfWord == 0) || (idxOfCrossword == 1 && word == verticalHotWord))
										{
								result.push(' ('  + getTranslationByName("hot", translations) + ')');
										}
							result.push('</td></tr>');
										}

						//Prize Results
						result.push('<tr><td class="tablehead" colspan="' + crosswordLetter.length + '">');
						result.push(getTranslationByName("results", translations));
						result.push('</tr></td>');

						//Words Found
						result.push('<tr><td class="tablebody" colspan="' + crosswordLetter.length + '">');
						result.push(getTranslationByName("wordsFound", translations) + ': ');
						result.push(matchCount);
						result.push('</td></tr>');
								
						//Win Amount
						result.push('<tr><td class="tablebody" colspan="' + crosswordLetter.length + '">');
						result.push(getTranslationByName("crossword", translations) + ' ' + (idxOfCrossword+1) + ' ' + getTranslationByName("win", translations) + ': ');
						return result.join('');
							}

					function close()
							{
						return '</td></tr></table><br/>';
							}

					function findWinAmount(jsonContext, prizeValues, prizeNames, idxOfCrossword)
							{
						var prizeOfCrosswordBoards = {};
						var prizeValuesArray = prizeValues.slice(1, prizeValues.length).split('|');
						var prizeNamesArray = prizeNames.slice(1, prizeNames.length).split(',');

						var result = 0;
						
						for(var idxOfPrize = 0; idxOfPrize < prizeNamesArray.length; ++idxOfPrize)
						{
							var prizeNameArray = prizeNamesArray[idxOfPrize].split(' ');
						
							if(prizeNameArray[2] == 'Match')
						{	
								prizeOfCrosswordBoards[prizeNameArray[1] + '_' + prizeNameArray[3]] = prizeValuesArray[idxOfPrize];

							}
							else if(prizeNameArray[2] == 'Hot')
							{
								prizeOfCrosswordBoards[prizeNameArray[1] + '_' + prizeNameArray[2]] = prizeValuesArray[idxOfPrize];
							}
								}

						var scenario = getScenario(jsonContext);
						var crosswords = scenario.split("|");
						var crosswordBoards = [];
						var crosswordLetters = [];			

						for(var numOfCrossword = 0; numOfCrossword < crosswords.length; ++numOfCrossword)
								{
							var crosswordContent = crosswords[numOfCrossword].split(",");
							crosswordBoards[numOfCrossword] = crosswordContent[0];
							crosswordLetters[numOfCrossword] = crosswordContent[1];
								}
						var crosswordLetter = crosswordLetters[idxOfCrossword].split("");

						var crosswordWords = getCrosswordWords(crosswordBoards[idxOfCrossword]);
						var verticalHotWord = findVerticalHotWord(crosswordBoards[idxOfCrossword]);
						var matchCount = 0;
						var hotWordMatched= false;
						for(var idxOfWord = 0; idxOfWord < crosswordWords.length; ++idxOfWord)
								{
							var word = crosswordWords[idxOfWord];
							matchChecked = checkMatch(crosswordLetter, word);
							if(matchChecked)
							{
								++matchCount;
								if((idxOfCrossword == 0 && idxOfWord == 0) || (idxOfCrossword == 1 && word == verticalHotWord))
								{
									hotWordMatched=true;
								}
							}
						}
						
						if((idxOfCrossword+1) + '_' + matchCount in prizeOfCrosswordBoards)
						{
							result = prizeOfCrosswordBoards[(idxOfCrossword+1) + '_' + matchCount];
							}
						
						if(hotWordMatched && (idxOfCrossword+1) + '_Hot' in prizeOfCrosswordBoards)
						{
							result += prizeOfCrosswordBoards[(idxOfCrossword+1) + '_Hot'];
							}

						return result+'';
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					function getCrosswordWords(crosswordBoard)
					{
						var crosswordRows = [];
						var crosswordCols = [];
						var lineStringRow = "";
						var lineStringCol = "";
						for(var x = 0; x < crosswordWidth; ++x)
					{
							for(var y = 0; y < crosswordHeight; ++y)
						{
								lineStringRow += crosswordBoard[y + (x * crosswordHeight)];
								lineStringCol += crosswordBoard[x + (y * crosswordWidth)];
							}
							crosswordRows.push(lineStringRow);
							crosswordCols.push(lineStringCol);
							lineStringRow = "";
							lineStringCol = "";
						}

						var crosswordWords = [];						
						for(var i = 0; i < crosswordRows.length; ++i)
							{
							addWords(crosswordRows[i], crosswordWords);
							}
						
						for(var i = 0; i < crosswordCols.length; ++i)
						{
							addWords(crosswordCols[i], crosswordWords);
						}
						
						return crosswordWords;
					}

					function findVerticalHotWord(crosswordBoard)
					{
						var hotWord = [];
						var index = crosswordWidth - 1;

						var letter = crosswordBoard[index];
						
						while(letter != '-')
						{
							hotWord.push(letter); 
							index += crosswordWidth;
							letter = crosswordBoard[index];
						}

						return hotWord.join('');
					}

					function addWords(checkForWords, wordsArray)
					{
						var word = "";
						var count = 0;
						for(var char = 0; char < checkForWords.length; ++char)
						{
							if(checkForWords.charAt(char) != '-')
							{
								word += checkForWords.charAt(char);
							}
							if(checkForWords.charAt(char) == '-' || char + 1 == checkForWords.length)
							{
								if(word.length >= 3)
								{
									wordsArray.push(word);
									count++;
								}
								word = "";
								continue;
							}
						}
					}

					// Input: string of the drawn Letters
					// Output: true all letters of word are in the drawn letters, false if not
					function checkMatch(drawnLetters, word)
					{
						for(var i = 0; i < word.length; ++i)
						{
							if(drawnLetters.indexOf(word[i]) <= -1)
							{
								return false;
							}
						}

						return true;
					}
					
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								//registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="prizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>
				
				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>
				
				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, 0)" disable-output-escaping="yes" />
				<x:call-template name="Utils.ApplyConversionByLocale">
					<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="my-ext:findWinAmount($odeResponseJson, string($prizeValues), string($prizeNames), 0)" />
					<x:with-param name="code" select="/output/denom/currencycode" />
					<x:with-param name="locale" select="//translation/@language" />
				</x:call-template>
			
				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, 1)" disable-output-escaping="yes" />
				<x:call-template name="Utils.ApplyConversionByLocale">
					<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="my-ext:findWinAmount($odeResponseJson, string($prizeValues), string($prizeNames), 1)" />
					<x:with-param name="code" select="/output/denom/currencycode" />
					<x:with-param name="locale" select="//translation/@language" />
				</x:call-template>
				<x:value-of select="my-ext:close()" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
				<x:text>|</x:text>
				<x:value-of select="text()" />
			</x:template>
			
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
