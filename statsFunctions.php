<?php
error_reporting(E_ERROR);

class CorrelationEngine
{
	var $arraySets;
	var $usableCount;
	var $fishersZ;
	var $standardError;
	var $lower95;
	var $upper95;
	var $lower99;
	var $upper99;
	

	function CorrelationEngine()
	{
		$this->arraySets	= array();
	}
	
	function Correlation($inputArray1, $inputArray2)
	{
		$this->arraySets	= array();
		$this->usableCount	= 0;
		$totalLength = count($inputArray1);
		$this->arraySets[0]->data = array();
		$this->arraySets[1]->data = array();
		$this->arraySets[0]->sum = 0;
		$this->arraySets[1]->sum = 0;
		
		for ($i = 0; $i < $totalLength; $i++)
		{
			if ($inputArray1[$i] != NULL && $inputArray2[$i] != NULL)
			{
				$this->usableCount++;
				$this->arraySets[0]->data[] = $inputArray1[$i];
				$this->arraySets[1]->data[] = $inputArray2[$i];
				$this->arraySets[0]->sum += $inputArray1[$i];
				$this->arraySets[1]->sum += $inputArray2[$i];
			}
		}
		if ($this->usableCount <= 3)
		{
			// No data to correlate
			$this->lower95 = 0;
			$this->upper95 = 0;
			$this->lower99 = 0;
			$this->upper99 = 0;
			return 0;
		}
		$this->arraySets[0]->average = $this->arraySets[0]->sum / $this->usableCount;
		$this->arraySets[1]->average = $this->arraySets[1]->sum / $this->usableCount;
		$correlation = 0;

		$k = $this->SumProductMeanDeviation();
		$ssmd1 = $this->SumSquareMeanDeviation(0);
		$ssmd2 = $this->SumSquareMeanDeviation(1);
		$product = $ssmd1 * $ssmd2;
		$res = sqrt($product);
		if ($res == 0)
		{
			return 0; // Probably no mean deviation - only one value??
		}
		$correlation = $k / $res;
		// Can't take log of zero
		if ($correlation > 0.9995)
		{
			$this->lower95 = 1;
			$this->upper95 = 1;
			$this->lower99 = 1;
			$this->upper99 = 1;
			return 1;
		}
		else if ($correlation < -0.9995)
		{
			$this->lower95 = -1;
			$this->upper95 = -1;
			$this->lower99 = -1;
			$this->upper99 = -1;
			return -1;
		}
		$fishersZ = 0.5 * (log(1 + $correlation) - log(1 - $correlation)); // This is needed because correlation is not normally distributed
		$standardError = 1 / (sqrt($this->usableCount - 3));
		$lower95Z = $fishersZ - (1.96 * $standardError);
		$upper95Z = $fishersZ + (1.96 * $standardError);
		$lower99Z = $fishersZ - (2.58 * $standardError);
		$upper99Z = $fishersZ + (2.58 * $standardError);
		
		$this->lower95 = (pow(M_E, 2 * $lower95Z) - 1) / (pow(M_E, 2 * $lower95Z) + 1);
		$this->upper95 = (pow(M_E, 2 * $upper95Z) - 1) / (pow(M_E, 2 * $upper95Z) + 1);
		$this->lower99 = (pow(M_E, 2 * $lower99Z) - 1) / (pow(M_E, 2 * $lower99Z) + 1);
		$this->upper99 = (pow(M_E, 2 * $upper99Z) - 1) / (pow(M_E, 2 * $upper99Z) + 1);
		
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