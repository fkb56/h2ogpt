#!/bin/sh

# NOTE: start in h2ogpt repo base directory
# i.e. can run below to update both spaces (assumes repos already existed, else will have to login HF for each)
# (h2ollm) jon@pseudotensor:~/h2ogpt$ ./spaces/chatbot/repo_to_spaces.sh h2ogpt-chatbot ; ./spaces/chatbot/repo_to_spaces.sh h2ogpt-chatbot2

spacename=${1:-h2ogpt-chatbot}
echo "Space name: $spacename"

# NOTE: start in h2ogpt repo base directory

h2ogpt_hash="$(git rev-parse HEAD)"

ln ../../generate.py .
mkdir -p src/
cp -rL ../../src/gen.py ../../src/evaluate_params.py ../../src/gradio_runner.py ../../src/gradio_themes.py ../../h2o-logo.svg ../../LICENSE ../../src/stopping.py ../../src/prompter.py ../../src/enums.py ../../src/utils.py ../../src/utils_langchain.py ../../src/client_test.py ../../src/gpt_langchain.py ../../src/create_data.py ../../src/h2oai_pipeline.py ../../src/gpt4all_llm.py ../../src/loaders.py ../../requirements.txt ../../iterators ../../reqs_optional ../../gradio_utils ../../src/serpapi.py ../../src/db_utils.py src
cd ..

rm -rf "${spacename}"
git clone https://huggingface.co/spaces/h2oai/"${spacename}"
cd "${spacename}"
git reset --hard origin/main
git pull --rebase

rm -rf app.py generate.py src
cd ../..
cp -rL generate.py  spaces/"${spacename}"/
mkdir -p spaces/"${spacename}"/src/
cd spaces/chatbot
cp -rL src/*  ../"${spacename}"/src/
cd ../"${spacename}"/

ln -s generate.py app.py

## for langchain support and gpt4all support
mv requirements.txt requirements.txt.001
## avoid gpt4all, hit ERROR: Could not build wheels for llama-cpp-python, which is required to install pyproject.toml-based projects
#cat requirements.txt.001 requirements_optional_langchain.txt requirements_optional_gpt4all.txt >> requirements.txt
cat requirements.txt.001 ../../reqs_optional/requirements_optional_langchain.txt ../../reqs_optional/requirements_optional_langchain.txt ../../reqs_optional/requirements_optional_faiss.txt ../../reqs_optional/requirements_optional_langchain.gpllike.txt >> requirements.txt
rm -rf requirements.txt.001

git add app.py generate.py src/*
git commit -m "Update with h2oGPT hash ${h2ogpt_hash}"
## ensure write token used and login with git control: huggingface-cli login --token <HUGGING_FACE_HUB_TOKEN> --add-to-git-credential
git push
#
echo "WARNING: Also change sdk_version: x.xx.xx in README.md in space"
