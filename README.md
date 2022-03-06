### Description for the Project

This project done and presented in July 2020. 
This is highlighting the modification method that I build, but the code is used for simplifying the simulation.
It was my first experience to build a coding script end to end.
The code is running in MATLAB, and so far away from a perfect code.

This project was about combining a fuzzy concept, fuzzy c-means clustering, and markov-chain concept to predict a value for the next 1 period.
Here is the detail for the concepts:
1. The fuzzy concept was using a triangular fuzzy number and median method (the common one used).
2. The fuzzy c-means clustering was using for clustering a dataset into certain group that optimal. 
  There is a calculation to get the optimize number of group that will be used. (code FCM.m)
3. The markov-chain concept was using to finalize how to predict the value.

Two method was compared here are the combination within markov-chain concept and without it.

I used a stock price of one emiten (emiten code: WSKT) for my prediction simulation.
The result from simulation show the modification within markov-chain having the higher accuration rate than another one.
