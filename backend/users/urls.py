from django.urls import path, include
from .views import UserCreator, UserRetriever, UserDestroyer

urlpatterns = [
    path("users/user/<int:pk>/", UserRetriever.as_view()),
    path("users/create/", UserCreator.as_view()),
    path("users/delete_user/<int:pk>/", UserDestroyer.as_view())
]
