from django.shortcuts import render
from django.core.handlers.wsgi import WSGIRequest
from django.shortcuts import get_object_or_404
from django.contrib.auth.mixins import UserPassesTestMixin

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import generics as rfg
from rest_framework.permissions import IsAuthenticated, BasePermission

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from .models import User, Student, Parent, Teacher
from .serializer import UserSerializer, StudentSerializer, ParentSerializer, TeacherSerializer


class StudentList(rfg.ListAPIView):
    """Получение списка всех студентов"""
    queryset = Student.objects.all()
    serializer_class = StudentSerializer


class IsAdminUser(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_superuser


class UserCreator(rfg.CreateAPIView):
    """Создание пользователя

    Создаётся запись в таблицах User и таблице, согласно указанной роли.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]

    def test_func(self):
        return self.request.user.is_superuser


class UserManager(rfg.RetrieveUpdateDestroyAPIView):
    """Получение, изменение и удаление пользователя"""
    queryset = User.objects.all()
    serializer_class = UserSerializer


class StudentCreater(rfg.CreateAPIView):
    """ Создание студента

    Создаётся запись в таблицах User и Student.
    """
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class StudentManager(rfg.RetrieveUpdateAPIView):
    """Получение, изменение и удаление студента"""
    queryset = Student.objects.all()
    serializer_class = StudentSerializer


class ParentManager(rfg.RetrieveUpdateAPIView):
    """Получение, изменение и удаление родителя"""
    queryset = Parent.objects.all()
    serializer_class = ParentSerializer


class TeacherManager(rfg.RetrieveUpdateAPIView):
    """Получение, изменение и удаление родителя"""
    queryset = Teacher.objects.all()
    serializer_class = TeacherSerializer


class KinshipManager(APIView):
    """Управление связью между родителем и ребёнком"""

    @swagger_auto_schema(request_body=None, responses={201: ParentSerializer})
    def post(self, request: WSGIRequest, student_id: int, parent_id: int, format=None):
        """Добавление связи между родителем и ребёнком"""
        student: Student = get_object_or_404(Student, id=student_id)
        parent: Parent = get_object_or_404(Parent, id=parent_id)
        parent.students.add(student)
        parent.save()
        return Response(ParentSerializer(parent).data, status=status.HTTP_201_CREATED)

    @swagger_auto_schema(request_body=None, responses={200: ParentSerializer})
    def delete(self, request: WSGIRequest, student_id: int, parent_id: int, format=None):
        """Удаление связи между родителем и ребёнком"""
        student: Student = get_object_or_404(Student, id=student_id)
        parent: Parent = get_object_or_404(Parent, id=parent_id)
        parent.students.remove(student)
        parent.save()
        return Response(ParentSerializer(parent).data, status=status.HTTP_200_OK)


@swagger_auto_schema(method='get', request_body=None, responses={200: StudentSerializer(many=True)})
@api_view(['GET'])
def get_children(request: WSGIRequest, parent_id: int):
    """Получение детей родителя"""
    parent = get_object_or_404(Parent, id=parent_id)
    students = parent.students.all()
    return Response(StudentSerializer(students, many=True).data, status=status.HTTP_200_OK)


@swagger_auto_schema(method='get', request_body=None, responses={200: ParentSerializer(many=True)})
@api_view(['GET'])
def get_parents(request: WSGIRequest, student_id: int):
    """Получение родителей ребёнка"""
    student = get_object_or_404(Student, id=student_id)
    parents = student.parents.all()
    return Response(ParentSerializer(parents, many=True).data, status=status.HTTP_200_OK)
