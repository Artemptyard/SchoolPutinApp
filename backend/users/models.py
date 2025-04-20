from django.contrib.auth.models import AbstractUser
from django.db import models
from phonenumber_field.modelfields import PhoneNumberField

# Create your models here.
class User(AbstractUser):
    ROLE_CHOICES = [('student', 'Ученик'), ('teacher', 'Преподаватель'), ('parent', 'Родитель')]
    role = models.CharField(choices=ROLE_CHOICES, max_length=20)
    middle_name = models.CharField(max_length=50, blank=True)
    phone_number = PhoneNumberField(region='RU', blank=True)

class Student(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    grade = models.CharField(max_length=20, null=True)

class Teacher(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)

class Parent(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    students = models.ManyToManyField(Student, related_name="parents")
