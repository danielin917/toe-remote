#pragma once
#include<Arduino.h>
template<typename T>
class Vector{
	T* array;
	//length of array
	size_t length;
	//data in array
	size_t count;
	
	void grow()
	{
		T* creation = new T[length * 2];
		memcpy(creation, array, length*sizeof(T));
		delete [] array;
		array = creation;
		length *= 2;
	}
public:
	Vector():array(new T[1]), length(1), count(0){}
	
	void push_back(T data)
	{
		if(count == length)
			grow();
		
		array[count] = data;
		count += 1;
	}
	void pop_back()
	{
		
	}
	size_t size()
	{
		return count;
	}
	T operator[](int x)
	{
		return array[x];
	}	
};
