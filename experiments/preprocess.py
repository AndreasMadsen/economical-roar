import pathlib
import argparse
import os.path as path

from ecoroar.dataset import datasets
from ecoroar.tokenizer import HuggingfaceTokenizer

thisdir = path.dirname(path.realpath(__file__))
parser = argparse.ArgumentParser()
parser.add_argument('--persistent-dir',
                    action='store',
                    default=pathlib.Path(__file__).absolute().parent.parent,
                    type=pathlib.Path,
                    help='Directory where all persistent data will be stored')

if __name__ == "__main__":
    args = parser.parse_args()

    for model_name in ['roberta-base']:
        tokenizer = HuggingfaceTokenizer(model_name, persistent_dir=args.persistent_dir)

        for name, Dataset in datasets.items():
            dataset = Dataset(persistent_dir=args.persistent_dir)
            for item in dataset.train(tokenizer):
                pass
            for item in dataset.valid(tokenizer):
                pass
            for item in dataset.test(tokenizer):
                pass
