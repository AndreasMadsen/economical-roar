
import json
import argparse
import os
import pathlib

from tqdm import tqdm
import pandas as pd
import plotnine as p9
import numpy as np

from ecoroar.dataset import datasets
from ecoroar.plot import bootstrap_confint, annotation

def select_target_metric(df):
    idx, cols = pd.factorize('results.' + df.loc[:, 'target_metric'])
    return df.assign(
        metric = df.reindex(cols, axis=1).to_numpy()[np.arange(len(df)), idx]
    )


parser = argparse.ArgumentParser(
    description = 'Plots the 0% masking test performance given different training masking ratios'
)
parser.add_argument('--persistent-dir',
                    action='store',
                    default=pathlib.Path(__file__).absolute().parent.parent,
                    type=pathlib.Path,
                    help='Directory where all persistent data will be stored')
parser.add_argument('--stage',
                    action='store',
                    default='both',
                    type=str,
                    choices=['preprocess', 'plot', 'both'],
                    help='Which export stage should be performed. Mostly just useful for debugging.')
parser.add_argument('--performance-metric',
                    action='store',
                    default='primary',
                    type=str,
                    choices=['primary', 'loss', 'accuracy'],
                    help='Which metric to use as a performance metric.')

if __name__ == "__main__":
    pd.set_option('display.max_rows', None)
    args, unknown = parser.parse_known_args()

    dataset_mapping = pd.DataFrame([
        {
            'args.dataset': dataset._name,
            'target_metric': dataset._early_stopping_metric if args.performance_metric == 'primary' else args.performance_metric,
            'baseline': dataset.majority_classifier_test_performance()[
                dataset._early_stopping_metric if args.performance_metric == 'primary' else args.performance_metric
            ]
        }
        for dataset in datasets.values()
    ])
    model_mapping = pd.DataFrame([
        { 'args.model': 'roberta-m15', 'model_category': 'masking-ratio' },
        { 'args.model': 'roberta-m20', 'model_category': 'masking-ratio' },
        { 'args.model': 'roberta-m30', 'model_category': 'masking-ratio' },
        { 'args.model': 'roberta-m40', 'model_category': 'masking-ratio' },
        { 'args.model': 'roberta-m50', 'model_category': 'masking-ratio' },
        { 'args.model': 'roberta-sb', 'model_category': 'size' },
        { 'args.model': 'roberta-sl', 'model_category': 'size' }
    ])

    if args.stage in ['both', 'preprocess']:
        # Read JSON files into dataframe
        results = []
        files = sorted((args.persistent_dir / 'results').glob('faithfulness_*.json'))
        for file in tqdm(files, desc='Loading faithfulness .json files'):
            with open(file, 'r') as fp:
                try:
                    results.append(json.load(fp))
                except json.decoder.JSONDecodeError:
                    print(f'{file} has a format error')

        df_faithfulness = pd.json_normalize(results).explode('results', ignore_index=True)
        results = pd.json_normalize(df_faithfulness.pop('results')).add_prefix('results.')
        df_faithfulness = pd.concat([df_faithfulness, results], axis=1)
        df_faithfulness = df_faithfulness.query('`results.masking_ratio` > 0')

        # Read JSON files into dataframe
        results = []
        files = sorted((args.persistent_dir / 'results').glob('masking_*.json'))
        for file in tqdm(files, desc='Loading masking .json files'):
            with open(file, 'r') as fp:
                try:
                    results.append(json.load(fp))
                except json.decoder.JSONDecodeError:
                    print(f'{file} has a format error')
        df_masking = pd.json_normalize(results).explode('results', ignore_index=True)
        results = pd.json_normalize(df_masking.pop('results')).add_prefix('results.')
        df_masking = pd.concat([df_masking, results], axis=1)

        # Filter df_masking
        df_masking = df_masking.query('`args.max_masking_ratio` == 100 & \
                                       `args.masking_strategy` == "half-det" & \
                                       `results.masking_ratio` == 0')
        df_goal = pd.concat([
                df_masking.assign(**{'args.explainer': explainer})
                for explainer in df_faithfulness['args.explainer'].unique()
            ])

        # Select test metric
        df = (pd.concat([df_faithfulness, df_goal])
              .merge(dataset_mapping, on='args.dataset')
              .merge(model_mapping, on='args.model')
              .transform(select_target_metric))
        df.to_csv('test.csv')

    if args.stage in ['preprocess']:
        os.makedirs(f'{args.persistent_dir}/pandas', exist_ok=True)
        df.to_pickle(f'{args.persistent_dir}/pandas/faithfulness.pd.pkl.xz')
    elif args.stage in ['plot']:
        df = pd.read_pickle(f'{args.persistent_dir}/pandas/faithfulness.pd.pkl.xz')

    if args.stage in ['both', 'plot']:
        # Compute confint and mean for each group

        for model_category in ['masking-ratio', 'size']:
            df_model_category = df.query('`model_category` == @model_category')
            if df_model_category.shape[0] == 0:
                print(f'Skipping model category "{model_category}", no observations.')
                continue

            df_plot = (df_model_category
                .groupby(['args.model', 'args.dataset', 'args.explainer', 'results.masking_ratio'], group_keys=True)
                .apply(bootstrap_confint(['metric']))
                .reset_index())

            df_baseline = (df_model_category
                .groupby(['args.model', 'args.dataset', 'results.masking_ratio'], group_keys=True)
                .apply(bootstrap_confint(['baseline']))
                .reset_index())

            # Generate plot
            p = (p9.ggplot(df_plot, p9.aes(x='results.masking_ratio'))
                + p9.geom_ribbon(p9.aes(ymin='metric_lower', ymax='metric_upper', fill='args.explainer'), alpha=0.35)
                + p9.geom_point(p9.aes(y='metric_mean', color='args.explainer'))
                + p9.geom_line(p9.aes(y='metric_mean', color='args.explainer'))
                + p9.geom_line(p9.aes(y='baseline_mean'), color='black', data=df_baseline)
                + p9.facet_grid("args.model ~ args.dataset", scales="free_x", labeller=annotation.model.labeller)
                + p9.scale_x_continuous(name='Masking ratio')
                + p9.scale_y_continuous(
                    labels=lambda ticks: [f'{tick:.0%}' for tick in ticks],
                    name='IM masked performance'
                )
                + p9.scale_color_discrete(
                    breaks = annotation.explainer.breaks,
                    labels = annotation.explainer.labels,
                    aesthetics = ["colour", "fill"],
                    name='importance measure (IM)'
                )
                + p9.scale_shape_discrete(guide=False))

            # Save plot, the width is the \linewidth of a collumn in the LaTeX document
            os.makedirs(f'{args.persistent_dir}/plots', exist_ok=True)
            p.save(f'{args.persistent_dir}/plots/faithfulness_m-{model_category}.pdf', width=3*6.30045 + 0.2, height=7, units='in')
            p.save(f'{args.persistent_dir}/plots/faithfulness_m-{model_category}.png', width=3*6.30045 + 0.2, height=7, units='in')
