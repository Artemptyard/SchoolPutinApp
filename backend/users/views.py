from django.shortcuts import render
from django.core.handlers.wsgi import WSGIRequest

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from drf_yasg.utils import swagger_auto_schema
from rest_framework import generics as rfg

from .models import User, Student
from .serializer import UserSerializer, StudentSerializer


# class StudentList(rfg.ListAPIView):
#     queryset = Student.objects.all()
#     serializer_class = StudentSerializer


class UserRetriever(rfg.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UserCreator(rfg.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UserDestroyer(rfg.DestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
