#!/bin/bash

mysqladmin shutdown
sleep 2

exec mysqld_safe
