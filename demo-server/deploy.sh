#/bin/bash
GIT_HASH=$(git rev-parse HEAD)
./gradlew build -x test
cp $(find ./build/libs/ -name '*.jar') ./app.jar
sudo docker build . -t demo-server:$GIT_HASH
sudo docker tag demo-server:$GIT_HASH localhost:5000/demo-server:$GIT_HASH
sudo docker push localhost:5000/demo-server:$GIT_HASH
