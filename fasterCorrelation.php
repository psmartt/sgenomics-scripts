<?php
error_reporting(E_ERROR);

class CorrelationEngine
{
	var $arraySets;
	var $usableCount;
	var $averages;
	var $SSs;

	function CorrelationEngine()
	{
		$this->arraySets	= array();
	}
	
	function Correlation($inputArray1, $inputArray2, $average1, $average2, $SS1, $SS2)
	{
		$this->arraySets	= array();
		$this->usableCount	= 0;
		$totalLength = count($inputArray1);
		$this->arraySets[0]->data = array();
		$this->arraySets[1]->data = array();
		// $this->arraySets[0]->sum = 0;
		// $this->arraySets[1]->sum = 0;
		
		for ($i = 0; $i < $totalLength; $i++)
		{
			if ($inputArray1[$i] != NULL && $inputArray2[$i] != NULL)
			{
				$this->usableCount++;
				$this->arraySets[0]->data[] = $inputArray1[$i];
				$this->arraySets[1]->data[] = $inputArray2[$i];
				// $this->arraySets[0]->sum += $inputArray1[$i];
				// $this->arraySets[1]->sum += $inputArray2[$i];
			}
		}
		if ($this->usableCount == 0)
		{
			return 0; // No data to correlate
		}
		// $this->arraySets[0]->average = $this->arraySets[0]->sum / $this->usableCount;
		// $this->arraySets[1]->average = $this->arraySets[1]->sum / $this->usableCount;
		$this->arraySets[0]->average = $average1;
		$this->arraySets[1]->average = $average2;
		$correlation = 0;

		$k = $this->SumProductMeanDeviation();
		// $ssmd1 = $this->SumSquareMeanDeviation(0);
		// $ssmd2 = $this->SumSquareMeanDeviation(1);
		// $product = $ssmd1 * $ssmd2;
		$product = $SS1 * $SS2;
		$res = sqrt($product);
		if ($res == 0)
		{
			return 0; // Probably no mean deviation - only one value??
		}
		$correlation = $k / $res;
		return $correlation;
	}

	function SumProductMeanDeviation()
	{
		$sum = 0;
		
		for($i = 0; $i < $this->usableCount; $i++)
		{
			$sum += $this->ProductMeanDeviation($i);
		}
		
		return $sum;
	}

	function ProductMeanDeviation($item)
	{
		return ($this->MeanDeviation(0, $item) * $this->MeanDeviation(1, $item));
	}

	function SumSquareMeanDeviation($arrayNum)
	{
		$sum = 0;
		
		for($i=0; $i<$this->usableCount; $i++)
		{
			$sum += $this->SquareMeanDeviation($arrayNum, $i);
		}
		
		return $sum;
	}

	function SquareMeanDeviation($arrayNum, $item)
	{
		$meanDeviation = $this->MeanDeviation($arrayNum, $item);
		return $meanDeviation * $meanDeviation;
	}

	function SumMeanDeviation($arrayNum)
	{
		$sum = 0;
		
		for($i = 0; $i < $this->usableCount; $i++)
		{
			$sum += $this->MeanDeviation($arrayNum, $i);
		}
		
		return $sum;
	}

	function MeanDeviation($arrayNum, $item)
	{
		return $this->arraySets[$arrayNum]->data[$item] - $this->arraySets[$arrayNum]->average;
	}

}