from django.shortcuts import render
from rest_framework.views import APIView
from .models import *
from .serializers import *
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.hashers import make_password, check_password
from rest_framework import mixins
from rest_framework import generics
from rest_framework_simplejwt.tokens import RefreshToken # 👈 1. Import the token generator
from rest_framework.response import Response
from rest_framework import status

# Create your views here.
class CreateAccountView(APIView):
    def get(self, request):
        user = User.objects.all()
        serializedUser = UserSerializer(user, many=True)
        return Response(serializedUser.data, status=status.HTTP_200_OK)

    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")
        date_of_birth = request.data.get("date_of_birth")
        phone_number = request.data.get("phone_number")

        if User.objects.filter(username=username).exists():
            return Response({"error": "User account with this username already exist"}, status=status.HTTP_400_BAD_REQUEST)
        else:
            request.data["password"] = make_password(password)
            serializedUser = UserSerializer(data=request.data)
            if serializedUser.is_valid():
                new_user = serializedUser.save()
                UserProfile.objects.create(
                user=new_user,
                date_of_birth=date_of_birth,
                phone_number=phone_number
                )
                return Response({"message": "User account created successfully", "data": serializedUser.data}, status=status.HTTP_201_CREATED)
            return Response(serializedUser.errors, status=status.HTTP_400_BAD_REQUEST)
        
class UserProfileListView(mixins.ListModelMixin, mixins.CreateModelMixin, generics.GenericAPIView):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer

    def get(self, request):
        return self.list(request)
    
class LoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")

        # 1. Validate input presence
        if not email or not password:
            return Response(
                {"error": "Email and password are required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 2. Check if user exists
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {"error": "Invalid email or password"}, # Generic message is safer for production security
                status=status.HTTP_400_BAD_REQUEST
            )

        # 3. Check password matching
        if not check_password(password, user.password):
            return Response(
                {"error": "Invalid email or password"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 4. Generate Cryptographic JWT Token Pair
        refresh = RefreshToken.for_user(user)

        # 5. Build and return your updated payload
        return Response({
            "message": "Login successful",
            "access": str(refresh.access_token),  # Sent to Flutter for API authorization
            "refresh": str(refresh),              # Sent to Flutter to refresh expired tokens
            "user_id": user.id,
            "first_name": user.first_name,
            "last_name": user.last_name,
        }, status=status.HTTP_200_OK)