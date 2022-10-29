# Advanced database project

This is a project for the course Advanced Database at the Efrei Paris. The goal of this project is to create a database for a network of theatrical companies. The database is created using the Oracle PL/SQL database management system. We focus on the ticket and the show management system of the network.

## Authors

Jiaen LIU  
Jin-Young BAE

## Main features

- Create a database for a network of theatrical companies. 12 tables to store the data.
- Create a lot of triggers to ensure the integrity and logic of the data.
- Create some functions and procedure to assist user's behavior.
  1. Finding the performances which do not have enough actors
     - A function to find the whether a performance do not have enough actors
     - A procedure to find all the performances which do not have enough actor
  2. Finding the actor which is free for the above performance
     - A function to find whether an actor is free for that performance
     - A procedure to find the actor is free in all actors in table actor
  3. A function to calculate the free sits for a performance
  4. A function to calculate the total sales for a performance
  5. A function to calculate the total sales for a company/theater

- Create some trigger to automatically update the data when a change is made.



