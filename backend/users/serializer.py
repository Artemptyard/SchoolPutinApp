from rest_framework import serializers
from .models import *

from rest_framework import serializers
from .models import User, Student, Teacher, Parent
from phonenumber_field.serializerfields import PhoneNumberField

class UserSerializer(serializers.ModelSerializer):
    phone_number = PhoneNumberField(default="+79193221792")

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'middle_name', 'phone_number', 'role']


class StudentSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Student
        fields = ['id', 'user', 'grade']

    def create(self, validated_data: dict):
        """Добавление нового пользователя Student

        Новая запись в таблицах User и Student.
        Изменение собственных полей Student.
        """
        user_data = validated_data.pop('user')
        user_data["role"] = "student"
        user = User.objects.create_user(**user_data)
        student = Student.objects.get(user_id=user.id)
        # Изменение соственных полей
        for attr, value in validated_data.items():
            setattr(student, attr, value)
        student.save()
        return student


class TeacherSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Teacher
        fields = ['id', 'user']


class ParentSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    students = StudentSerializer(many=True)

    class Meta:
        model = Parent
        fields = ['id', 'user', 'students']
