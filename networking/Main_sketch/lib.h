#pragma once
#include <stddef.h>
#include <string.h>

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
        for (unsigned i = 0; i < length; ++i) {
            creation[i] = array[i];
        }
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
		if(count > 0)
			count -= 1;	
		else
		{
			/* bounds check throw?*/
		}
	}
	size_t size()
	{
		return count;
	}
	T operator[](int x)
	{
		/*some sort of bounds check
		if(x >= count)
		{
			throw;
		}
		*/
		return array[x];
	}	
	~Vector()
	{
		 if(array)
			 delete[] array;
	}
};
