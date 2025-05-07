from rest_framework import serializers
from .models import *

from rest_framework import serializers
from .models import User, Student, Teacher, Parent

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'middle_name', 'phone_number', 'role']


class StudentSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Student
        fields = ['id', 'user', 'grade']


class TeacherSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Teacher
        fields = ['id', 'user']


class ChildrenSerializer(serializers.ModelSerializer):
    """Cериализатор для отображения детей у родителя"""
    user = UserSerializer()

    class Meta:
        model = Student
        fields = ['id', 'user', 'grade']


class ParentSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    students = ChildrenSerializer(many=True)

    class Meta:
        model = Parent
        fields = ['id', 'user', 'students']
