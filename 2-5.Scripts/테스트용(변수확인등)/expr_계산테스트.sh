#!/bin/bash
var1=10
var2=`expr $var1 + 10`
var3=`expr $var1 - 10`
var4=`expr $var1 \* 10`
var5=`expr $var1 / 10`

echo "var1 : $var1"
echo "var2 : $var2"
echo "var3 : $var3"
echo "var4 : $var4"
echo "var5 : $var5"
